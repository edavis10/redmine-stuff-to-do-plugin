# StuffToDo relates a user to another object at a specific postition
# in a list.
#
# Supported objects:
# * Issue
# * Project
class StuffToDo < ActiveRecord::Base
  USE = {
    'All' => '0',
    'Only Issues' => '1',
    'Only Projects' => '2'
  }

  belongs_to :stuff, :polymorphic => true
  belongs_to :user
  acts_as_list :scope => :user
  
  if Rails::VERSION::MAJOR >= 3
    scope :doing_now, lambda { |user|
      {
        :conditions => { :user_id => user.id },
        :order => 'position ASC',
        :limit => 5
      }
    }
  else
    named_scope :doing_now, lambda { |user|
      {
        :conditions => { :user_id => user.id },
        :order => 'position ASC',
        :limit => 5
      }
    }
  end
  
  # TODO: Rails bug
  #
  # ActiveRecord ignores :offset if :limit isn't added also.  But since we 
  # want all the records, we need to provide a limit that will include everything
  #
  # http://dev.rubyonrails.org/ticket/7257
  #
  if Rails::VERSION::MAJOR >= 3
    scope :recommended, lambda { |user|
      {
        :conditions => { :user_id => user.id },
        :order => 'position ASC',
        :limit => self.count,
        :offset => 5
      }
    }
  else
    named_scope :recommended, lambda { |user|
      {
        :conditions => { :user_id => user.id },
        :order => 'position ASC',
        :limit => self.count,
        :offset => 5
      }
    }
  end
  
  # Filters the issues that are available to be added for a user.
  #
  # A filter can be a record:
  #
  # * User - issues are assigned to this user
  # * IssueStatus - issues with this status
  # * IssuePriority - issues with this priority
  #
  def self.available(user, filter=nil)
    return [] if filter.blank?

    if filter.is_a?(Project)
      potential_stuff_to_do = active_and_visible_projects.sort
    else
      potential_stuff_to_do = Issue.find(:all,
                                         :include => [:status, :priority, :project],
                                         :conditions => conditions_for_available(filter),
                                         :order => "#{Issue.table_name}.created_on DESC")
    end

    stuff_to_do = StuffToDo.find(:all, :conditions => { :user_id => user.id }).collect(&:stuff)
    
    return potential_stuff_to_do - stuff_to_do
  end

  def self.using_projects_as_items?
    ['All', 'Only Projects'].include?(use_setting)
  end

  def self.using_issues_as_items?
    ['All', 'Only Issues'].include?(use_setting)
  end

  # Callback used to destroy all StuffToDos when an object is removed and
  # send an email if a user is below the What's Recommend threshold
  def self.remove_associations_to(associated_object)
    user_ids = []
    associated_object.stuff_to_dos.each do |stuff_to_do|
      user_ids << stuff_to_do.user_id if stuff_to_do.user_id
      stuff_to_do.destroy
    end

    # Deliver an email for each user who is below the threshold
    user_ids.uniq.each do |user_id|
      count = self.count(:conditions => { :user_id => user_id})
      threshold = Setting.plugin_stuff_to_do_plugin['threshold']

      if threshold && threshold.to_i >= count
        user = User.find_by_id(user_id)
        StuffToDoMailer.recommended_below_threshold(user, count).deliver
      end
    end
    
    return true
  end
  
  # Destroys all +NextIssues+ on an +issue+ that are not the assigned to user
  def self.remove_stale_assignments(issue)
    if issue.assigned_to_id.nil?
      self.destroy_all(['stuff_id = (?)', issue.id])
    else
      self.destroy_all(['stuff_id = (?) AND user_id NOT IN (?)',
                             issue.id,
                             issue.assigned_to_id])
    end
  end
  
  # Reorders the list of StuffToDo items for +user+ to be in the order of
  # +ids+.  New StuffToDos will be created if needed and old
  # StuffToDos will be removed if they are unassigned.
  #
  # Project based ids need to be prefixed with +project+
  def self.reorder_list(user, ids)
    ids ||= []
    #id_position_mapping = ids.to_hash
    i = 0
    id_position_mapping = {}
    ids.each do |value|
      id_position_mapping[i] = value
      i = i+1
    end

    issue_ids = {}
    project_ids = {}

    id_position_mapping.each do |key,value|
      if value.match(/project/i)
        project_ids[key] = value.sub(/project/i,'').to_i
      else
        issue_ids[key] = value.to_i
      end
    end

    reorder_issues(user, issue_ids)
    reorder_projects(user, project_ids)
  end

  private

  def self.reorder_issues(user, issue_ids)
    reorder_items('Issue', user, issue_ids)
  end

  def self.reorder_projects(user, project_ids)
    reorder_items('Project', user, project_ids)
  end

  def self.reorder_items(type, user, ids)
    list = self.find_all_by_user_id_and_stuff_type(user.id, type)
    stuff_to_dos_found = list.collect { |std| std.stuff_id.to_i }

    remove_missing_records(user, stuff_to_dos_found, ids.values)

    ids.each do |position, id|
      if existing_list_position = stuff_to_dos_found.index(id.to_i)
        position = position + 1  # acts_as_list is 1 based
        stuff_to_do = list[existing_list_position]
        stuff_to_do.insert_at(position)
      else
        # Not found in list, so create a new StuffToDo item
        stuff_to_do = self.new
        stuff_to_do.stuff_id = id
        stuff_to_do.stuff_type = type
        stuff_to_do.user_id = user.id

        stuff_to_do.save # TODO: Check return
        
        # Have to resave next_issue since acts_as_list automatically moves it
        # to the bottom on create
        stuff_to_do.insert_at(position + 1)  # acts_as_list is 1 based
      end
    end
  
  end

  # Destroys saved records that are +ids_found_in_database+ but are
  # not in +ids_to_use+
  def self.remove_missing_records(user, ids_found_in_database, ids_to_use)
    removed = ids_found_in_database - ids_to_use
    removed.each do |id|
      removed_stuff_to_do = self.find_by_user_id_and_stuff_id(user.id, id)
      removed_stuff_to_do.destroy
    end
  end

  # Redmine 0.8.x compatibility method.
  def self.active_and_visible_projects
    if ::Project.respond_to?(:active) && ::Project.respond_to?(:visible)
      return ::Project.active.visible
    else
      return ::Project.find(:all, :conditions => Project.visible_by)
    end
  end

  def self.use_setting
    USE.index(Setting.plugin_stuff_to_do_plugin['use_as_stuff_to_do'])
  end

  def self.conditions_for_available(filter_by)
    scope = self
    conditions = "#{IssueStatus.table_name}.is_closed = false"
    conditions << " AND (" << "#{Project.table_name}.status = %d" % [Project::STATUS_ACTIVE] << ")"
    case 
    when filter_by.is_a?(User)
      conditions << " AND (" << "assigned_to_id = %d" % [filter_by.id] << ")"
    when filter_by.is_a?(IssueStatus), filter_by.is_a?(Enumeration)
      table_name = filter_by.class.table_name
      conditions << " AND (" << "#{table_name}.id = (%d)" % [filter_by.id] << ")"
    end
    conditions
  end
end

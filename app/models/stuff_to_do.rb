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

  belongs_to :stuff, polymorphic: true
  belongs_to :user
  acts_as_list :scope => :user
  
  if Rails::VERSION::MAJOR >= 3
    scope :doing_now, lambda { |user|
      where( :user_id => user.id )
      .order('position ASC')
      .limit(5)
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
      where( :user_id => user.id )
        .order('position ASC')
        .limit(self.count)
        .offset(5)
    }
  else
    named_scope :recommended, lambda { |user|
      {
        :conditions => [ "user_id = ?", user.id ],
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
  def self.available(user, project, filter=nil)
    return [] if filter.blank?
      
    if filter.is_a?(Project)
      potential_stuff_to_do = active_and_visible_projects(user).sort
    else
      if User.current.allowed_to?(:view_all_reportee_issues, nil, { :global => true }) or (User == User.current)
        visible_issues =  Issue
      else
        visible_issues =  Issue.visible       
      end
      potential_stuff_to_do = visible_issues
                                     .where( conditions_for_available(user, filter, project) )
                                     .eager_load( :status, :priority, :project )
                                     .order("#{Issue.table_name}.created_on DESC")
    end

    stuff_to_do = StuffToDo.where( :user_id => user.id ).collect(&:stuff)
    
    return potential_stuff_to_do - stuff_to_do
  end

  def self.assigned(user)

    return StuffToDo.find(:all, :conditions => { :user_id => user.id }).collect(&:stuff)
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
      if Rails::VERSION::MAJOR >= 3
        count = self.select( "user_id = %d" % user_id ).count( :id )
      else
        count = self.count(:conditions => { :user_id => user_id})
      end

      threshold = Setting.plugin_stuff_to_do_plugin['threshold']

      if threshold && threshold.to_i >= count
        user = User.find_by_id(user_id)
        StuffToDoMailer.recommended_below_threshold(user, count)
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
    list = self.where(user_id: user.id, stuff_type: type).to_a
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
      removed_stuff_to_do = self.find_by(:user_id => user.id, :stuff_id => id)
      removed_stuff_to_do.destroy
    end
  end

  def self.remove(user_id, id)
    removed_stuff_to_do = self.find_by_user_id_and_stuff_id(user_id, id)
    removed_stuff_to_do.destroy
  end
  
  def self.add(user_id, id, to_front)
    if (find_by_user_id_and_stuff_id(user_id, id).nil?) #make sure it's not already there
      stuff_to_do = self.new
      stuff_to_do.stuff_id = id
      stuff_to_do.stuff_type = 'Issue'
      stuff_to_do.user_id = user_id
      stuff_to_do.save # TODO: Check return
              
      if to_front == true
        stuff_to_do.insert_at(1)
      end
    end
  end

  def self.active_and_visible_projects(user=User.current)
    projects = Project.active.where(Project.visible_condition(user))
    if !User.current.allowed_to_globally?(:view_all_reportee_issues, {}) and (user != User.current)
      projects = projects.where(Project.visible_condition(User.current))
    end
    projects
  end

  def self.use_setting
    USE.key(Setting.plugin_stuff_to_do_plugin['use_as_stuff_to_do'])
  end

  def self.conditions_for_available(user, filter_by, project)
    scope = self
    #for Postgres:# conditions = "#{IssueStatus.table_name}.is_closed = false"
    conditions = "#{IssueStatus.table_name}.is_closed = false"
    conditions << " AND (" << "#{Project.table_name}.status = %d" % [Project::STATUS_ACTIVE] << ")"
    conditions << " AND ((" << "assigned_to_id = %d" % [user.id] << ")"
    if(user.is_a?(User))
      user.group_ids.each do |group_id|
        conditions << " OR (" << "assigned_to_id = %d" % [group_id] << ")"
      end
    end
    conditions << ")"
    case 
    when filter_by.is_a?(IssueStatus), filter_by.is_a?(Enumeration)
      table_name = filter_by.class.table_name
      conditions << " AND (" << "#{table_name}.id = (%d)" % [filter_by.id] << ")"
    end
    conditions << ( " AND (" << "#{Issue.table_name}.project_id = %d" % [project.id] << ")" ) unless project.nil?
    conditions
  end
end

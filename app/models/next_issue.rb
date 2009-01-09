# NextIssue relates a user to an issue at a specific postition in a list
class NextIssue < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user
  acts_as_list :scope => :user
  
  named_scope :doing_now, lambda { |user|
    {
      :conditions => { :user_id => user.id },
      :limit => 5,
      :order => 'position ASC'
    }
  }

  # TODO: Rails bug
  #
  # ActiveRecord ignores :offset if :limit isn't added also.  But since we 
  # want all the records, we need to provide a limit that will include everything
  #
  # http://dev.rubyonrails.org/ticket/7257
  #
  named_scope :recommended, lambda { |user|
    {
      :conditions => { :user_id => user.id },
      :limit => NextIssue.count,
      :offset => 5,
      :order => 'position ASC'
    }
  }
  
  # Filters the issues that are available to be added for a user.
  #
  # A filter can be:
  #
  # * :user - issues are assigned to this user
  # * :status - issues with this status
  # * :priority - issues with this priority
  #
  def self.available(user, filter = { })
    if filter.nil? || filter.empty?
      return []
    elsif filter[:user]
      user = filter[:user]
      issues = Issue.find(:all,
                          :include => :status,
                          :conditions => ["assigned_to_id = ? AND #{IssueStatus.table_name}.is_closed = ?",user.id, false ],
                          :order => 'created_on DESC')
    elsif filter[:status]
      status = filter[:status]
      issues = Issue.find(:all,
                          :include => :status,
                          :conditions => ["#{IssueStatus.table_name}.id = (?) AND #{IssueStatus.table_name}.is_closed = ?", status.id, false ],
                          :order => 'created_on DESC')
    elsif filter[:priority]
      priority = filter[:priority]
      issues = Issue.find(:all,
                          :include => [:status, :priority],
                          :conditions => ["#{Enumeration.table_name}.id = (?) AND #{IssueStatus.table_name}.is_closed = ?", priority.id, false ],
                          :order => 'created_on DESC')
    end
    next_issues = NextIssue.find(:all, :conditions => { :user_id => user.id }).collect(&:issue)

    
    return issues - next_issues
  end
  
  # Callback used to destroy all NextIssues when an issue is removed and
  # send an email if a user is below the What's Recommend threshold
  def self.closing_issue(issue)
    return false unless issue.closed?
    user_ids = []
    NextIssue.find(:all, :conditions => { :issue_id => issue.id }).each do |next_issue|
      user_ids << next_issue.user_id if next_issue.user_id
      next_issue.destroy
    end

    # Deliver an email for each user who is below the threshold
    user_ids.uniq.each do |user_id|
      count = NextIssue.count(:conditions => { :user_id => user_id})
      threshold = Setting.plugin_stuff_to_do_plugin['threshold']

      if threshold && threshold.to_i >= count
        user = User.find_by_id(user_id)
        NextIssueMailer.deliver_recommended_below_threshold(user, count)
      end
    end
    
    return true
  end
  
  # Destroys all +NextIssues+ on an +issue+ that are not the assigned to user
  def self.remove_stale_assignments(issue)
    if issue.assigned_to_id.nil?
      NextIssue.destroy_all(['issue_id = (?)', issue.id])
    else
      NextIssue.destroy_all(['issue_id = (?) AND user_id NOT IN (?)',
                             issue.id,
                             issue.assigned_to_id])
    end
  end
  
  # Reorders the list of NextIssues for +user+ to be in the order of
  # +issue_ids+.  New NextIssues will be created and if needed and old
  # NextIssues will be removed if they are unassigned.
  def self.reorder_list(user, issue_ids)
    issue_ids ||= []
    issue_ids.map! {|issue_id| issue_id.to_i }
    list = NextIssue.find_all_by_user_id(user.id)
    next_issues_found = list.collect { |next_issue| next_issue.issue_id.to_i }
    
    # Remove NextIssues that are not in the issue_ids
    removed_issues = next_issues_found - issue_ids
    removed_issues.each do |issue_id|
      removed_next_issue = NextIssue.find_by_user_id_and_issue_id(user.id, issue_id)
      removed_next_issue.destroy
    end
    
    issue_ids.each do |issue_id|
      if existing_list_position = next_issues_found.index(issue_id.to_i)
        position = issue_ids.index(issue_id) + 1  # acts_as_list is 1 based
        next_issue = list[existing_list_position]
        next_issue.insert_at(position)
      else
        # Not found in list, so create a new NextIssue
        next_issue = NextIssue.new
        next_issue.issue_id = issue_id
        next_issue.user_id = user.id

        next_issue.save # TODO: Check return
        
        # Have to resave next_issue since acts_as_list automatically moves it
        # to the bottom on create
        next_issue.insert_at(issue_ids.index(issue_id) + 1)  # acts_as_list is 1 based
      end
      
    end
  end
end

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

  named_scope :recommended, lambda { |user|
    {
      :conditions => { :user_id => user.id },
      :limit => 10,
      :offset => 5,
      :order => 'position ASC'
    }
  }
  
  def self.available(user)
    issues = Issue.find(:all,
                        :include => :status,
                        :conditions => ["assigned_to_id = ? AND #{IssueStatus.table_name}.is_closed = ?",user.id, false ])
    next_issues = NextIssue.find(:all, :conditions => { :user_id => user.id }).collect(&:issue)

    return issues - next_issues
  end
  
  def self.closing_issue(issue)
    return false unless issue.closed?
    NextIssue.find(:all, :conditions => { :issue_id => issue.id }).each do |next_issue|
      next_issue.destroy
    end
    
    return true
  end
  
  def self.reorder_list(user, issue_ids)
    issue_ids.map! {|issue_id| issue_id.to_i }
    list = NextIssue.find_all_by_user_id_and_issue_id(user.id, issue_ids)
    next_issues_found = list.collect { |next_issue| next_issue.issue_id.to_i }
    
    # Remove NextIssues that are not in the issue_ids
    removed_issues = next_issues_found - issue_ids
    removed_issues.each do |issue_id|
      NextIssue.destroy(issue_id)
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

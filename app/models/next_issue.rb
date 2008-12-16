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
end

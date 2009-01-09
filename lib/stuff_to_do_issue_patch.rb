require_dependency 'issue'

# Patches Redmine's Issues dynamically.  Adds a +after_save+ filter.
module StuffToDoIssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      after_save :update_next_issues
      
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    # This will update all NextIssues assigned to the Issue
    #
    # * When an issue is closed, NextIssue#closing_issue will be called to
    #   update the set of NextIssues
    # * When an issue is reassigned, any previous (stale) NextIssues will
    #   be removed
    def update_next_issues
      self.reload
      NextIssue.closing_issue(self) if self.closed?
      NextIssue.remove_stale_assignments(self)
      return true
    end
  end    
end

# Add module to Issue
Issue.send(:include, StuffToDoIssuePatch)




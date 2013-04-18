# Patches Redmine's Issues dynamically.  Adds a +after_save+ filter.
module StuffToDoIssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      after_save :update_next_issues
      has_many :stuff_to_dos, :as => :stuff
      has_and_belongs_to_many :time_grid_users, :class_name => 'User', :join_table => 'time_grid_issues_users'

      if Rails::VERSION::MAJOR >= 3
        scope :with_time_entries_for_user, lambda {|user_id|
          {
            :include => :time_entries,
            :conditions => ["#{TimeEntry.table_name}.user_id = (?)", user_id]
          }
        }
      else
        named_scope :with_time_entries_for_user, lambda {|user_id|
          {
            :include => :time_entries,
            :conditions => ["#{TimeEntry.table_name}.user_id = (?)", user_id]
          }
        }
      end
      
      if Rails::VERSION::MAJOR >= 3
        scope :with_time_entries_within_date, lambda {|date_from, date_to,|
          {
            :include => :time_entries,
            :conditions => ["#{TimeEntry.table_name}.spent_on > (:from) AND #{TimeEntry.table_name}.spent_on < (:to)",
                            {:from => date_from, :to => date_to}]
          }
        }
      else
        named_scope :with_time_entries_within_date, lambda {|date_from, date_to,|
          {
            :include => :time_entries,
            :conditions => ["#{TimeEntry.table_name}.spent_on > (:from) AND #{TimeEntry.table_name}.spent_on < (:to)",
                            {:from => date_from, :to => date_to}]
          }
        }
      end

      # Redmine 0.8.x compatibility method
      unless ::Issue.respond_to?(:visible)
        if Rails::VERSION::MAJOR >= 3
          scope :visible, lambda {|*args| { :include => :project,
              :conditions => Project.allowed_to_condition(args.first || User.current, :view_issues) } }
        else
          named_scope :visible, lambda {|*args| { :include => :project,
              :conditions => Project.allowed_to_condition(args.first || User.current, :view_issues) } }
        end
      end
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    # This will update all NextIssues assigned to the Issue
    #
    # * When an issue is closed, NextIssue#remove_associations_to will be called to
    #   update the set of NextIssues
    # * When an issue is reassigned, any previous (stale) NextIssues will
    #   be removed
    def update_next_issues
      self.reload
      StuffToDo.remove_associations_to(self) if self.closed?
      StuffToDo.remove_stale_assignments(self)
      return true
    end
  end    
end

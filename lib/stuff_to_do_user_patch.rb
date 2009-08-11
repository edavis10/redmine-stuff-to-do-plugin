# Patches Redmine's Users dynamically.
module StuffToDoUserPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      unloadable
      has_and_belongs_to_many :time_grid_issues, :class_name => 'Issue', :join_table => 'time_grid_issues_users'
    end
  end
end


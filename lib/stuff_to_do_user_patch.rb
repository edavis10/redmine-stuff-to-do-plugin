# Patches Redmine's Users dynamically.
module StuffToDoUserPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      has_and_belongs_to_many :time_grid_issues, class_name: "Issue", join_table: "time_grid_issues_users"
    end
  end

  module InstanceMethods
      def allowed_to_view_all_reportees?
        self.allowed_to?(:view_all_users_stuff_to_do, nil, :global => :true)
      end
  end
end


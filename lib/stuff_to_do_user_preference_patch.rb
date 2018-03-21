# Patches Redmine's UserPreferences dynamically.
module StuffToDoUserPreferencePatch
  def self.included(base) # :nodoc:
    base.class_eval do
      safe_attributes 'stuff_to_do_enabled',
          'stuff_to_do_view_all_reportees',
          'stuff_to_do_view_all_reportees'
    end
  end
end

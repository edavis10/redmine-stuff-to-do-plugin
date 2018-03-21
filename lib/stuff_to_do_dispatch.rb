
require_dependency 'project'
require_dependency 'issue'
require_dependency 'user'
require_dependency 'user_preference'

require 'stuff_to_do_project_patch';
require 'stuff_to_do_issue_patch';
require 'stuff_to_do_user_patch';
require 'stuff_to_do_user_preference_patch';

Project.send(:include, StuffToDoProjectPatch)
Issue.send(:include, StuffToDoIssuePatch)
User.send(:include, StuffToDoUserPatch)
UserPreference.send(:include, StuffToDoUserPreferencePatch)

# Needed for the compatibility check
begin
  require_dependency 'issue_priority'
rescue LoadError
  # TimeEntryActivity is not available
end

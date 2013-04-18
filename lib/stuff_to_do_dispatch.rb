
require_dependency 'project'
require_dependency 'issue'
require_dependency 'user'

require 'stuff_to_do_project_patch';
require 'stuff_to_do_issue_patch';
require 'stuff_to_do_user_patch';

Project.send(:include, StuffToDoProjectPatch)
Issue.send(:include, StuffToDoIssuePatch)
User.send(:include, StuffToDoUserPatch)
  
# Needed for the compatibility check
begin
  require_dependency 'issue_priority'
rescue LoadError
  # TimeEntryActivity is not available
end



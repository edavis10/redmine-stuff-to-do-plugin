require 'redmine'

Dir[File.join(File.dirname(__FILE__),'vendor','plugins','*')].each do |dir|
  path = File.join(dir, 'lib')
  $LOAD_PATH << path
  Dependencies.load_paths << path
  Dependencies.load_once_paths.delete(path)
end

# Patches to Ruby, oh my
require 'stuff_to_do_array_patch'

# Patches to the Redmine core.
require 'dispatcher'

Dispatcher.to_prepare do
  require_dependency 'project'
  require_dependency 'issue'
  require_dependency 'user'

  Project.send(:include, StuffToDoProjectPatch)
  Issue.send(:include, StuffToDoIssuePatch)
  User.send(:include, StuffToDoUserPatch)
  
  # Needed for the compatibility check
  begin
    require_dependency 'issue_priority'
  rescue LoadError
    # TimeEntryActivity is not available
  end

end

Redmine::Plugin.register :stuff_to_do_plugin do
  name 'Stuff To Do Plugin'
  author 'Eric Davis'
  url 'https://projects.littlestreamsoftware.com/projects/show/redmine-stuff-to-do'
  author_url 'http://www.littlestreamsoftware.com'
  description "The Stuff To Do plugin allows a user to order and prioritize the issues they are doing into a specific order. It will also allow other privilged users to reorder the user's workload."
  version '0.4.0'

  requires_redmine :version_or_higher => '0.8.0'

  settings(:partial => 'settings/stuff_to_do_settings',
           :default => {
             'use_as_stuff_to_do' => '0',
             'threshold' => '1',
             'email_to' => 'example1@example.com,example2@example.com',
             'use_time_grid' => '0'
           })

  menu(:top_menu, :stuff_to_do, {:controller => "stuff_to_do", :action => 'index'}, :caption => :stuff_to_do_title, :if => Proc.new{ User.current.logged? })

end

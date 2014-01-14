Redmine::Plugin.register :redmine_reminder do
  name 'Redmine reminder'
  author 'Kevin Neuenfeldt'
  description 'This plugin can be used to automatically send emails to officers of issues which are about to expire.'
  version '0.0.1'
  url ''
  author_url ''

  settings :default => { :intervals => '' }, :partial => 'settings/redmine_reminder_settings'
end

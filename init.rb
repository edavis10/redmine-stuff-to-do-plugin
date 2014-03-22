require_dependency 'hooks/view_hooks'

Redmine::Plugin.register :redmine_reminder do
  name 'Redmine Reminder'
  author 'Kevin Neuenfeldt'
  description 'This plugin can be used to automatically send emails to assignees of issues which are about to expire.'
  version '0.2.0'
  url 'https://github.com/raafael911/redmine_reminder.git'
  author_url ''

  settings :default => { :days => 7 }, :partial => 'settings/redmine_reminder_settings'
end

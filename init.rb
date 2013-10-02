Redmine::Plugin.register :escalation_alert do
  name 'Escalataion Alert'
  author 'Kevin Neuenfeldt'
  description 'This plugin can be used to automatically send emails to officers of issues which are about to expire.'
  version '0.0.1'
  url ''
  author_url ''

  settings :default => { :intervals => '' }, :partial => 'settings/escalation_settings'
end

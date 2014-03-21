namespace :redmine do
  namespace :redmine_reminder do
    desc "Sends reminder mails from redmine reminder plugin"
    task :send_reminder_mails => :environment do
      ENV['days'] = Setting.plugin_redmine_reminder['days']
      users = []
      users += User.where(:type => 'User')
      users = users.find_all{|u| u.pref['subscribe_to_reminder']}
      ENV['users'] = users.map{|u| u.id.to_i}.to_s.delete("[]")
      Rake::Task['redmine:send_reminders'].invoke if users.size > 0
    end
  end
end
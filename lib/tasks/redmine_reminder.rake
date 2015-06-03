namespace :redmine do
  namespace :redmine_reminder do
    desc "Sends reminder mails from redmine reminder plugin"
    task :send_reminder_mails => :environment do
      subscribed_users = Array.new(User.where(:type => 'User').find_all{|u| u.pref['subscribe_to_reminder']})
      users_with_default_period = subscribed_users.find_all{|u| u.pref['custom_reminder_period_days'].nil?}
      users_with_custom_period = subscribed_users - users_with_default_period

      optionsDefault = {}
      optionsDefault[:days] = Setting.plugin_redmine_reminder['days'].to_i
      optionsDefault[:users] = users_with_default_period.map{|u| u.id.to_i}.to_s.delete("[]")

      Mailer.with_synched_deliveries do
        Mailer.reminders(optionsDefault) unless optionsDefault[:users].empty?
        users_with_custom_period.each do |u|
          optionsCustom = {:days => u.pref['custom_reminder_period_days'].to_i, :users => u.id}
          Mailer.reminders(optionsCustom)
        end
      end
    end
  end
end
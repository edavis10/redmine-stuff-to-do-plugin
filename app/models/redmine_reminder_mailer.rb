class RedmineReminderMailer < ActionMailer::Base

  include Redmine::I18n

  def self.default_url_options
    { :host => Setting.host_name, :protocol => Setting.protocol }
  end

  def reminder(issues, user)
    @issues = issues

    mail(:to => user.mail,
         :from => Setting.mail_from,
         :subject => t('redmine_reminder_mailer.mail_subject'),
         'X-Mailer' => 'Redmine',
         'X-Redmine-Host' => Setting.host_name,
         'X-Redmine-Site' => Setting.app_title,
         'X-Auto-Response-Suppress' => 'OOF',
         'Auto-Submitted' => 'auto-generated') do |format|
      format.html
      format.text if Setting.plain_text_mail?
    end
  end

end

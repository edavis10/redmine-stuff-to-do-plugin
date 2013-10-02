class EscalationMailer < ActionMailer::Base

  def escalation(issues, user)
    @issues = issues

    mail(:to => user.mail,
         :from => 'escalation@enervision.de',
         :subject => 'Escalation Notification') do |format|
      format.html
      format.text if Setting.plain_text_mail?
    end
  end

end
class EscalationMailer < ActionMailer::Base

  def escalation(issues, user)
    @issues = issues

    mail(:to => user.mail,
         :from => 'bugmaster@enervision.de',
         :subject => 'Redmine Wiedervorlage') do |format|
      format.html
      format.text if Setting.plain_text_mail?
    end
  end

end
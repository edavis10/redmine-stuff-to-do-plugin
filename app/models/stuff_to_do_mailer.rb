class StuffToDoMailer < Mailer
  def recommended_below_threshold(user, number_of_next_items)
    set_language_if_valid user.language
    if Rails::VERSION::MAJOR >= 3
      @to = Setting.plugin_stuff_to_do_plugin['email_to'].split(',')
      @subject = "What's Recommended is below the threshold"

      @threshold = Setting.plugin_stuff_to_do_plugin['threshold']
      @count = number_of_next_items
      @user = user

      mail(:to => @to, :subject => @subject, :template_name => "recommended_below_threshold")
    else
      recipients Setting.plugin_stuff_to_do_plugin['email_to'].split(',')
      subject "What's Recommended is below the threshold"

      body(
        :threshold => Setting.plugin_stuff_to_do_plugin['threshold'],
        :count => number_of_next_items,
        :user => user
      )

      render_multipart("recommended_below_threshold", body)
    end
  end
end

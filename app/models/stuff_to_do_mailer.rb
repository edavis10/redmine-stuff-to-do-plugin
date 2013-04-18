class StuffToDoMailer < Mailer
  def recommended_below_threshold(user, number_of_next_items)
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

        part :content_type => "text/plain", :body => render_message("recommended_below_threshold.text.erb", body)
        part :content_type => "text/html", :body => render_message("recommended_below_threshold.html.erb", body)
    end
  end
end

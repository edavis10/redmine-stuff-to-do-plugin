class NextIssueMailer < Mailer
  def recommended_below_threshold(user, number_of_next_items)
    recipients Setting.plugin_stuff_to_do_plugin['email_to'].split(',')
    subject "What's Recommended is below the threshold"
    
    body(
         :threshold => Setting.plugin_stuff_to_do_plugin['threshold'],
         :count => number_of_next_items,
         :user => user
         )

    part :content_type => "text/plain", :body => render_message("recommended_below_threshold.erb", body)
    part :content_type => "text/html", :body => render_message("recommended_below_threshold.text.html.rhtml", body)

  end
end

class NextIssueMailer < Mailer
  def recommended_below_threshold(user, number_of_next_items)
    recipients Setting.plugin_stuff_to_do_plugin['email_to'].split(',')
    subject "What's Recommended is below the threshold"
    
    body(
         :threshold => Setting.plugin_stuff_to_do_plugin['threshold'],
         :count => number_of_next_items,
         :user => user
         )
  end
end

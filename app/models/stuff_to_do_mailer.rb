class StuffToDoMailer < Mailer

	def recommended_below_threshold(user, number_of_next_items)

		mail(:to => Setting.plugin_stuff_to_do_plugin['email_to'],
		     :subject => "What's Recommended is below the threshold",
		     :threshold => Setting.plugin_stuff_to_do_plugin['threshold'], 
		     :count => number_of_next_items, 
		     :user => user) do |format|
			format.html { render :layout => 'recommended_below_threshold' }
			format.text { render :layout => 'recommended_below_threshold' }
		     end

	end

	def index
	end
end

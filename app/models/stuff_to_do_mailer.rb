#

class StuffToDoMailer < Mailer

	default :to => Setting.plugin_stuff_to_do_plugin['email_to']
	
	def index
	end

	def recommended_below_threshold(user, number_of_next_items)
		@user = user
		@number_of_next_items = number_of_next_items

		mail (:subject   => "What's Recommended is below the threshold",
		      :threshold => Setting.plugin_stuff_to_do_plugin['threshold'], 
		      :count     => number_of_next_items, 
		      :user      => user) do |format|
			format.text
			format.html 
		      end
	end
end

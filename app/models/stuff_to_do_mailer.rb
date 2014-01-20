
class StuffToDoMailer < Mailer
  add_template_helper(StuffToDoHelper)

  def index
  end

  def recommended_below_threshold(user, number_of_next_items)
    @user = user
    @number_of_next_items = number_of_next_items
    @threshold = Setting.plugin_stuff_to_do_plugin['threshold']
    
    mail(:subject   => "What's Recommended is below the threshold",
         :count     => number_of_next_items,
         :to        => Setting.plugin_stuff_to_do_plugin['email_to'],
         :user      => user) do |format|
      format.text
      format.html
          end
  end

  def periodic(user, doing_now, recommended)
    @user = user
    @doing_now = doing_now
    @recommended = recommended

    mail(:to => @user.mail,
         :subject => "Your Stuff To Do",
         :user => @user) do |format|
           format.text
           format.html
         end
  end

  def periodic_summary(users_stuff_to_dos_hash)
    @users_stuff_to_dos_hash = users_stuff_to_dos_hash
    @bypass_user_allowed_to_view = true
    mail(:to => Setting.plugin_stuff_to_do_plugin['email_to'],
         :subject => "Stuff To Do Team Summary",
         :bypass_user_allowed_to_view => @bypass_user_allowed_to_view,
         :users_stuff_to_do_hash => @users_stuff_to_do_hash) do |format|
           format.text
           format.html
         end
  end
end

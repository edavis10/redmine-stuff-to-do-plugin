class StuffToDoMailer < Mailer
  add_template_helper(StuffToDoHelper)

  default :to => Setting.plugin_stuff_to_do_plugin['email_to'].split(',')

  def index
  end

  def recommended_below_threshold(user, number_of_next_items)
    Rails.logger.error "Language system = #{Setting.default_language}"
    set_language_if_valid Setting.default_language
    Rails.logger.error "Language user = #{user.language}"
    set_language_if_valid user.language
    if Rails::VERSION::MAJOR >= 3
      @to = Setting.plugin_stuff_to_do_plugin['email_to'].split(',')
      @subject = "What's Recommended is below the threshold"

      @threshold = Setting.plugin_stuff_to_do_plugin['threshold']
      @count = number_of_next_items
      @user = user

      mail(:to => @to,
        :subject => @subject,
        :threshold => @threshold,
        :count => @count,
        :user => @user,
        :template_name => "recommended_below_threshold")
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
end

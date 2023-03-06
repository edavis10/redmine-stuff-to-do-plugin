
class StuffToDoMailer < Mailer
  if Rails::VERSION::MAJOR > 5
    helper StuffToDoHelper
  else
    add_template_helper(StuffToDoHelper)
  end

  default to: (Setting.plugin_stuff_to_do_plugin['email_to'] || "").split(',')

  def index
  end

  def recommended_below_threshold(user, number_of_next_items)
    Rails.logger.error "Language system = #{Setting.default_language}"
    set_language_if_valid Setting.default_language
    Rails.logger.error "Language user = #{user.language}"
    set_language_if_valid user.language
    @to = Setting.plugin_stuff_to_do_plugin['email_to'].split(',')
    @subject = "What's Recommended is below the threshold"

    @threshold = Setting.plugin_stuff_to_do_plugin['threshold']
    @count = number_of_next_items
    @user = user

    mail(to: @to,
      subject: @subject,
      threshold: @threshold,
      count: @count,
      user: @user,
      template_name: "recommended_below_threshold")
  end

  def periodic(user, doing_now, recommended)
    @user = user
    @doing_now = doing_now
    @recommended = recommended

    mail(to: @user.mail,
      subject: "Your Stuff To Do",
      user: @user)
  end

  def periodic_summary(user, users_stuff_to_dos_hash)
    @to = Setting.plugin_stuff_to_do_plugin['email_to'].split(',')
    @subject = "Stuff To Do Team Summary"
    @user = User.find_by_mail(@to.first)

    @users_stuff_to_dos_hash = users_stuff_to_dos_hash
    @bypass_user_allowed_to_view = true
    mail(to: @to,
      subject: @subject,
      bypass_user_allowed_to_view: @bypass_user_allowed_to_view,
      users_stuff_to_do_hash: @users_stuff_to_do_hash,
      user: @user)
  end
end

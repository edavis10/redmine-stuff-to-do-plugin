module Hooks
  class ViewHooks < Redmine::Hook::ViewListener
    render_on :view_my_account, :partial => 'account_settings/redmine_reminder_account_settings', :layout => false
  end
end
module MyPlugin
  class Hooks < Redmine::Hook::ViewListener
    # This just renders the partial in
    # app/views/hooks/my_plugin/_view_issues_form_details_bottom.rhtml
    # The contents of the context hash is made available as local variables to the partial.
    #
    # Additional context fields
    #   :issue  => the issue this is edited
    #   :f      => the form object to create additional fields
    render_on :view_issues_sidebar_queries_bottom,
          :partial => 'stuff_to_do/view_issues_sidebar_queries_bottom'
    render_on :view_issues_context_menu_start,
          :partial => 'stuff_to_do/view_issues_context_menu_start'
    render_on :view_my_account, :partial => 'account_settings/stuff_to_do_account_settings', :layout => false
    render_on :view_users_form, :partial => 'stuff_to_do_reportee/stuff_to_do_admin_reportee', :layout => false
  end
end

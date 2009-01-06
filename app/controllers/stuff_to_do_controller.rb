class StuffToDoController < ApplicationController
  before_filter :get_user
  helper :stuff_to_do
  
  def index
    @doing_now = NextIssue.doing_now(@user)
    @recommended = NextIssue.recommended(@user)
    @available = NextIssue.available(@user)
    
    @users = User.active
    @filters = filters_for_view
  end
  
  def reorder
    NextIssue.reorder_list(@user, params[:issue])
    @doing_now = NextIssue.doing_now(@user)
    @recommended = NextIssue.recommended(@user)
    @available = NextIssue.available(@user)

    respond_to do |format|
      format.html { redirect_to :action => 'index'}
      format.js { render :partial => 'panes', :layout => false}
    end
  end
  
  def available_issues
    @available = NextIssue.available(@user)

    respond_to do |format|
      format.html { redirect_to :action => 'index'}
      format.js { render :partial => 'right_panes', :layout => false}
    end
  end
  
  private
  
  def get_user
    render_403 unless User.current.logged?
    
    if params[:user_id] && params[:user_id] != User.current.id.to_s
      if User.current.admin?
        @user = User.find(params[:user_id])
      else
        render_403
      end
    else
      @user = User.current  
    end
  end
  
  def filters_for_view
    NextIssueFilter.new
  end
end

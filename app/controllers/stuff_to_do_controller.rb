class StuffToDoController < ApplicationController
  before_filter :get_user
  
  def index
    @doing_now = NextIssue.doing_now(@user)
    @recommended = NextIssue.recommended(@user)
    @available = NextIssue.available(@user)
    
    @users = User.active
  end
  
  def reorder
    NextIssue.reorder_list(@user, params[:issue])
    @doing_now = NextIssue.doing_now(@user)
    @recommended = NextIssue.recommended(@user)
    respond_to do |format|
      format.html { redirect_to :action => 'index'}
      format.js { render :partial => 'left_panes', :layout => false}
    end
  end
  
  private
  
  def get_user
    if params[:user_id] && User.current.admin?
      @user = User.find(params[:user_id])
    else
      @user = User.current  
    end
  end
end

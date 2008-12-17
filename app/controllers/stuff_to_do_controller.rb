class StuffToDoController < ApplicationController
  def index
    @doing_now = NextIssue.doing_now(User.current)
    @recommended = NextIssue.recommended(User.current)
    @available = NextIssue.available(User.current)
  end
  
  def reorder
    NextIssue.reorder_list(User.current, params[:issue])
    @doing_now = NextIssue.doing_now(User.current)
    @recommended = NextIssue.recommended(User.current)
    respond_to do |format|
      format.html { redirect_to :action => 'index'}
      format.js { render :partial => 'left_panes', :layout => false}
    end
  end
end

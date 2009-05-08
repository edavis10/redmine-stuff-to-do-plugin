class StuffToDoController < ApplicationController
  unloadable

  before_filter :get_user
  before_filter :require_admin, :only => :available_issues
  helper :stuff_to_do
  
  def index
    @doing_now = StuffToDo.doing_now(@user)
    @recommended = StuffToDo.recommended(@user)
    @available = StuffToDo.available(@user, :user => @user )
    
    @users = User.active
    @filters = filters_for_view
  end
  
  def reorder
    StuffToDo.reorder_list(@user, params[:stuff])
    @doing_now = StuffToDo.doing_now(@user)
    @recommended = StuffToDo.recommended(@user)
    @available = StuffToDo.available(@user, get_filters )

    respond_to do |format|
      format.html { redirect_to :action => 'index'}
      format.js { render :partial => 'panes', :layout => false}
    end
  end
  
  def available_issues
    @available = StuffToDo.available(@user, get_filters)

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
    StuffToDoFilter.new
  end
  
  def get_filters
    return { :user => @user } unless params[:filter]

    id = params[:filter].split('-')[-1]

    if params[:filter].match(/users/)
      return { :user => User.find_by_id(id) }
    elsif params[:filter].match(/priorities/)
      return { :priority => Enumeration.find_by_id(id) }
    elsif params[:filter].match(/statuses/)
      return { :status => IssueStatus.find_by_id(id) }
    elsif params[:filter].match(/projects/)
      return { :projects => true }
    else
      return nil
    end
  end
end

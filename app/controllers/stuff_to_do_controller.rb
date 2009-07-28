class StuffToDoController < ApplicationController
  unloadable

  before_filter :get_user
  before_filter :get_time_grid, :only => [:index, :time_grid, :add_to_time_grid]
  before_filter :require_admin, :only => :available_issues
  helper :stuff_to_do
  
  def index
    @doing_now = StuffToDo.doing_now(@user)
    @recommended = StuffToDo.recommended(@user)
    @available = StuffToDo.available(@user, default_filters )
    
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
  
  def time_grid
    respond_to do |format|
      format.html { redirect_to :action => 'index'}
      format.js { render :partial => 'time_grid', :layout => false}
    end
  end

  def add_to_time_grid
    # OPTIMIZE: Shouldn't need to run the finder for each issue_id
    params[:issue_ids].each do |id|
      issue = Issue.visible.find_by_id(id)
      @issues << issue if issue
    end unless params[:issue_ids].nil?
    @issues.uniq!
    time_grid
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
    return default_filters unless params[:filter]

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

  def default_filters
    if StuffToDo.using_issues_as_items?
      return { :user => @user }
    elsif StuffToDo.using_projects_as_items?
      return { :projects => true }
    else
      # Edge case
      return { }
    end
  end

  def get_time_grid
    @date = Date.parse(params[:date]) if params[:date]
    @date ||= Date.civil(params[:year].to_i, params[:month].to_i, params[:day].to_i) if params[:year] && params[:month] && params[:day]
    @date ||= Date.today
    
    @calendar = Redmine::Helpers::Calendar.new(@date, current_language, :week)
    @issues = Issue.visible.
      with_time_entries_for_user(User.current).
      with_time_entries_within_date(@calendar.startdt, @calendar.enddt)
  end
end

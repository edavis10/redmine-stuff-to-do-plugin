class StuffToDoController < ApplicationController
  unloadable

  before_filter :get_user
  before_filter :get_time_grid, :only => [:index, :time_grid]
  before_filter :require_admin, :only => :available_issues
  helper :stuff_to_do
  helper :timelog
  
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
    issue = Issue.visible.find_by_id(params[:issue_id])
    # Issue exists and isn't already in user's list
    if issue && !User.current.time_grid_issues.exists?(issue)
      User.current.time_grid_issues << issue
    end
    get_time_grid
    time_grid
  end

  def remove_from_time_grid
    issue = User.current.time_grid_issues.visible.find_by_id(params[:issue_id])
    User.current.time_grid_issues.delete(issue) if issue
    get_time_grid
    time_grid
  end

  def save_time_entry
    @time_entry = TimeEntry.new
    @time_entry.user = User.current
    if params[:time_entry] &&  params[:time_entry].first
      @time_entry.attributes = params[:time_entry].first
    end
    @time_entry.project = @time_entry.issue.project if @time_entry.issue
    respond_to do |format|
      if save_time_entry_from_time_grid(@time_entry)
        flash.now[:time_grid_notice] = l(:notice_successful_update)
        get_time_grid # after saving in order to get the updated data
        
        format.js { time_grid }
      else
        format.js { render :text => @time_entry.errors.full_messages.join(', '), :status => 403, :layout => false }
      end
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
    return default_filters unless params[:filter]

    id = params[:filter].split('-')[-1]

    if params[:filter].match(/users/)
      return User.find_by_id(id)
    elsif params[:filter].match(/priorities/)
      return Enumeration.find_by_id(id)
    elsif params[:filter].match(/statuses/)
      return IssueStatus.find_by_id(id)
    elsif params[:filter].match(/projects/)
      return Project.new
    else
      return nil
    end
  end

  def default_filters
    if StuffToDo.using_issues_as_items?
      return @user
    elsif StuffToDo.using_projects_as_items?
      return Project.new
    else
      # Edge case
      return { }
    end
  end

  def get_time_grid
    @date = parse_date_from_params
    @calendar = Redmine::Helpers::Calendar.new(@date, current_language, :week)
    @issues = User.current.time_grid_issues.visible.all(:order => "#{Issue.table_name}.id ASC")
    @time_entry = TimeEntry.new
  end

  # Wrap saving the TimeEntry because TimeEntries from the time grid should
  # require comments.
  def save_time_entry_from_time_grid(time_entry)
    time_entry.valid? # Run normal validations

    # Additional validations
    if time_entry.comments.blank?
      time_entry.errors.add(:comments, :empty)
    end

    if time_entry.errors.empty? && User.current.allowed_to?(:log_time, time_entry.project)
      return time_entry.save
    else
      return false
    end
  end

  def parse_date_from_params
    date = Date.parse(params[:date]) if params[:date]
    date ||= Date.civil(params[:year].to_i, params[:month].to_i, params[:day].to_i) if params[:year] && params[:month] && params[:day]
    date ||= Date.today
  end
end

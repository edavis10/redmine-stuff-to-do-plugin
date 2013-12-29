class StuffToDoController < ApplicationController
  unloadable
  
  include StuffToDoHelper
  
  before_filter :get_user, :get_project
  helper :stuff_to_do
  helper :custom_fields
  
  def index
    @doing_now = StuffToDo.doing_now(@user)
    @recommended = StuffToDo.recommended(@user)
    @available = StuffToDo.available(@user, @project, default_filters )

    @users = StuffToDoReportee.reportees_for(User.current)
    @users << User.current unless @users.include?(User.current)
    @filters = filters_for_view
    
    respond_to do |format|
        format.html { render :template => 'stuff_to_do/index', :layout => !request.xhr? }
        format.csv  { send_data(stuff_to_do_to_csv(@doing_now, @recommended, @available, @user, params), :type => 'text/csv; header=present', :filename => 'export.csv') }
    end
  end
  
  def delete
     if !params[:issue_id].nil? && !params[:user_id].nil?
       StuffToDo.remove(params[:user_id],  params[:issue_id] )
     end
     
    respond_to do |format|
      format.html { redirect_to_referer_or { render :text => ('Deleting Issue from stuff-to-do.'), :layout => true} }
      format.js { render :partial => 'stuff-to-do', :layout => false}
    end
  end
  
  def add
    if !params[:issue_id].nil? && !params[:user_id].nil?
      StuffToDo.add(params[:user_id], params[:issue_id], params[:to_front] == "true")         
    end
    respond_to do |format|
      format.html { redirect_to_referer_or { render :text => ('Adding issue to stuff-to-do.'), :layout => true} }
      format.js { render :partial => 'stuff-to-do', :layout => false}
    end
  end
  
  def reorder
    StuffToDo.reorder_list(@user, params[:stuff])
    @doing_now = StuffToDo.doing_now(@user)
    @recommended = StuffToDo.recommended(@user)
    @available = StuffToDo.available(@user, @project, get_filters )

    respond_to do |format|
      format.html { redirect_to :action => 'index'}
      format.js { render :partial => 'panes', :layout => false}
    end
  end
  
  def available_issues
    @available = StuffToDo.available(@user, @project, get_filters)

    respond_to do |format|
      format.html { redirect_to :action => 'index'}
      format.js { render :partial => 'right_panes', :layout => false}
    end
  end
  
  private
  
  def get_project
    if params[:project_id] && !params[:project_id].empty?
      @project = Project.where(:id => params[:project_id]).first
      if @project.nil?
        render_404
        return false
      end
    end
  end
  
  def get_user
    render_403 unless User.current.logged?
    
    if params[:user_id] && params[:user_id] != User.current.id.to_s
      if User.current.allowed_to?(:view_others_stuff_to_do, @project, :global => true)
        @user = User.find(params[:user_id])
      else
        render_403
      end
    else
      @user = User.current  
    end
  end
  
  def filters_for_view
    StuffToDoFilter.new(:user => @user)
  end

  def get_filters
    return default_filters if params[:filter].nil? or params[:filter].empty?

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

end

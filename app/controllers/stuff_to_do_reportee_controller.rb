class StuffToDoReporteeController < ApplicationController
  unloadable

  before_filter :get_user

  def index
    render :index, :locals => { :from_admin_menu => false }
  end
  
  def admin
    render :index, :layout => "admin", :locals => { :from_admin_menu => true }
  end

  def add
    unless params[:reportee_ids].nil?
      params[:reportee_ids].each do |reportee_id|
        if !StuffToDoReportee.new(:user => @user, :reportee => User.find(reportee_id)).save
          flash[:error] = l(:stuff_to_do_cannot_create_reportee_error)
        end
      end
    end
    
    unless params[:group_ids].nil?
      params[:group_ids].each do |group_id|
        if !StuffToDoReportee.new(:user => @user, :group => Group.find(group_id)).save
          flash[:error] = l(:stuff_to_do_cannot_create_reportee_error)
        end 
      end
    end
    
    respond_to do |format|
      format.html { redirect_to :controller => 'stuff_to_do_reportee', :action => 'index', :user_id => @user.id }
      format.js 
    end
  end

  def delete
    if !@user.nil? && !params[:reportee_id].nil?
      StuffToDoReportee.where(:user_id => @user.id, :reportee_id => params[:reportee_id]).each do |reportee|
        reportee.destroy
      end
    end
    
    if !@user.nil? && !params[:group_id].nil?
      StuffToDoReportee.where(:user_id => @user.id, :group_id => params[:group_id]).each do |group_reportee|
        group_reportee.destroy
      end
    end
    
    respond_to do |format|
          format.html { redirect_to :controller => 'stuff_to_do_reportee', :action => 'index', :user_id => @user.id }
          format.js 
    end
  end
  
  
  def get_user
    return deny_access unless User.current.logged?
    
    if params[:user_id]
      if User.current.admin? || (User.current.id.to_s == params[:user_id])
        @user = User.find(params[:user_id])
      else
        deny_access
      end
    else
      @user = User.current  
    end
  end
  
end

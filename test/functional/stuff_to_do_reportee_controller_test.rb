require File.expand_path('../../test_helper', __FILE__)

class StuffToDoReporteeControllerTest < ActionController::TestCase
  fixtures :users, :stuff_to_do_reportees, :groups_users
  
  def test_index
    get :index, :user_id => StuffToDoReportee.first.user_id
    assert_response 302, "return error if no permission"
      
    @request.session[:user_id] = 1
    get :index, :user_id => StuffToDoReportee.first.user_id
    assert_response :success, "allow if admin"
    assert_template 'index'
    
    @request.session[:user_id] = 4
    get :index, :user_id => StuffToDoReportee.first.user_id
    assert_response :success, "allow if viewing own"
    assert_template 'index'
  end
  
  def test_add
    @request.session[:user_id] = 4
    initial_size = StuffToDoReportee.count
    post :add, { :user_id => 4, :reportee_ids => [1] }
    assert_redirected_to :controller => "stuff_to_do_reportee", :action => "index", :user_id => 4
    assert_equal initial_size + 1, StuffToDoReportee.count
    
    initial_size = StuffToDoReportee.count
    post :add, { :user_id => 4, :reportee_ids => [5, 6] }
    assert_redirected_to :controller => "stuff_to_do_reportee", :action => "index", :user_id => 4
    assert_equal initial_size + 2, StuffToDoReportee.count
  end
  
  def test_delete
    @request.session[:user_id] = 4
    initial_size = StuffToDoReportee.count
    post :delete, { :user_id => 4, :reportee_id => 3 }
    assert_redirected_to :controller => "stuff_to_do_reportee", :action => "index", :user_id => 4
    assert_equal initial_size - 1, StuffToDoReportee.count
  end
  
  def test_group
    @request.session[:user_id] = 4
    initial_size = StuffToDoReportee.reportees_for(User.find(4)).count
      
    post :add, {:user_id => 4, :group_ids => [Group.first.id] }
    assert_redirected_to :controller => "stuff_to_do_reportee", :action => "index", :user_id => 4
    assert_equal (initial_size + Group.first.users.count), StuffToDoReportee.reportees_for(User.current).count
    assert_equal 1, StuffToDoReportee.groups_for(User.current).count
    
    
    post :delete, {:user_id => 4, :group_id => Group.first.id}
    assert_redirected_to :controller => "stuff_to_do_reportee", :action => "index", :user_id => 4
    assert_equal initial_size, StuffToDoReportee.reportees_for(User.current).count
    assert_equal 0, StuffToDoReportee.groups_for(User.current).count
    
  end
end

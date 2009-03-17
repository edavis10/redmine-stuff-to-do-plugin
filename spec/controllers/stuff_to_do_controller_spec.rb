require File.dirname(__FILE__) + '/../spec_helper'

describe StuffToDoController, '#index' do
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true, :language => :en)
    User.stub!(:current).and_return(@current_user)
    NextIssue.stub!(:available)
  end
  
  it 'should be successful' do
    get :index
    response.should be_success
  end
  
  it 'should render the index template' do
    get :index
    response.should render_template('index')
  end
  
  it 'should set @doing_now to the top 5 issues for the current user' do
    stuff = []
    5.times { stuff << mock('stuff') }
    NextIssue.should_receive(:doing_now).with(@current_user).and_return(stuff)
    get :index
    assigns[:doing_now].should have(5).things
  end

  it 'should set @recommended to the next 10 issues for the current user' do
    stuff = []
    10.times { stuff << mock('stuff') }
    NextIssue.should_receive(:recommended).with(@current_user).and_return(stuff)
    get :index
    assigns[:recommended].should have(10).things
  end
  
  it 'should set @available to the assigned issues that are not next issues for the current user' do
    stuff = []
    6.times { stuff << mock('stuff') }
    NextIssue.should_receive(:available).with(@current_user, { :user => @current_user }).and_return(stuff)
    get :index
    assigns[:available].should have(6).things
  end

  it 'should set @filters to for the view' do
    get :index
    assigns[:filters].should_not be_nil
  end
  
  it 'should build the filters using filters_for_view' do
    controller.should_receive(:filters_for_view)
    get :index
  end
end

describe StuffToDoController, '#index for another user as an administrator' do
  def get_index
    get :index, :user_id => @viewed_user.id
  end
  
  before(:each) do
    @current_user = mock_model(User, :admin? => true, :logged? => true, :language => :en)
    User.stub!(:current).and_return(@current_user)
    controller.stub!(:find_current_user).and_return(@current_user)
    @viewed_user = mock_model(User)
    User.stub!(:find).with(@viewed_user.id.to_s).and_return(@viewed_user)
    NextIssue.stub!(:available)
  end
  
  it 'should be successful' do
    get_index
    response.should be_success
  end
  
  it 'should render the index template' do
    get_index
    response.should render_template('index')
  end
  
  it 'should set @doing_now to the top 5 issues for the current user' do
    stuff = []
    5.times { stuff << mock('stuff') }
    NextIssue.should_receive(:doing_now).with(@viewed_user).and_return(stuff)
    get_index
    assigns[:doing_now].should have(5).things
  end

  it 'should set @recommended to the next 10 issues for the current user' do
    stuff = []
    10.times { stuff << mock('stuff') }
    NextIssue.should_receive(:recommended).with(@viewed_user).and_return(stuff)
    get_index
    assigns[:recommended].should have(10).things
  end
  
  it 'should set @available to the assigned issues that are not next issues for the current user' do
    stuff = []
    6.times { stuff << mock('stuff') }
    NextIssue.should_receive(:available).with(@viewed_user, { :user => @viewed_user }).and_return(stuff)
    get_index
    assigns[:available].should have(6).things
  end

end

describe StuffToDoController, '#index for another user as a user' do
  def get_index
    get :index, :user_id => @viewed_user.id
  end
  
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true, :language => :en)
    User.stub!(:current).and_return(@current_user)
    @viewed_user = mock_model(User)
  end

  it 'should not be successful' do
    get_index
    response.should_not be_success
  end
  
  it 'should return a 403 status code' do
    get_index
    response.code.should eql("403")
  end
  
  it 'should display the standard unauthorized page'
end

describe StuffToDoController, '#index with an unauthenticated user' do
  it 'should not be successful' do
    get :index
    response.should_not be_success
  end
  
  it 'should return a 403 status code' do
    get :index
    response.code.should eql("403")
  end
  
  it 'should display the standard unauthorized page'
end


describe StuffToDoController, '#reorder' do
  def post_reorder
    post :reorder, :issue => @ordered_list
  end
  
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true, :language => :en)
    User.stub!(:current).and_return(@current_user)
    @ordered_list = ["500", "100", "300"]
  end
  
  it 'should redirect' do
    post_reorder
    response.should be_redirect
  end
  
  it 'should be redirect to the index action' do
    post_reorder
    response.should redirect_to(:action => 'index')
  end
  
  it 'should reorder the Next Issues' do
    NextIssue.should_receive(:reorder_list).with(@current_user, @ordered_list)
    post_reorder
  end
end

# These intregrate the partial view
describe StuffToDoController, '#reorder with the js format' do
  def post_reorder
    post :reorder, :issue => @ordered_list, :format => 'js'
  end
  
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true, :language => :en)
    User.stub!(:current).and_return(@current_user)
    @ordered_list = ["500", "100", "300"]
    NextIssue.stub!(:doing_now).and_return([])
    NextIssue.stub!(:recommended).and_return([])
  end
  
  it 'should be successful' do
    post_reorder
    response.should be_success
  end
  
  it 'should be render the panes' do
    post_reorder
    response.should render_template('stuff_to_do/_panes')
  end
  
  it 'should reorder the Next Issues' do
    NextIssue.should_receive(:reorder_list).with(@current_user, @ordered_list)
    post_reorder
  end
  
  it 'should assign the doing now issues for the view' do
    post_reorder
    assigns[:doing_now].should_not be_nil
  end

  it 'should assign the recommended next issues for the view' do
    post_reorder
    assigns[:recommended].should_not be_nil
  end
end

describe StuffToDoController, '#reorder for another user as an administrator' do
  def post_reorder
    post :reorder, :issue => @ordered_list, :user_id => @viewed_user.id
  end
  
  before(:each) do
    @current_user = mock_model(User, :admin? => true, :logged? => true, :language => :en)
    User.stub!(:current).and_return(@current_user)
    controller.stub!(:find_current_user).and_return(@current_user)
    @viewed_user = mock_model(User)
    User.stub!(:find).with(@viewed_user.id.to_s).and_return(@viewed_user)
    @ordered_list = ["500", "100", "300"]
  end
  
  it 'should redirect' do
    post_reorder
    response.should be_redirect
  end
  
  it 'should be redirect to the index action' do
    post_reorder
    response.should redirect_to(:action => 'index')
  end
  
  it 'should reorder the Next Issues' do
    NextIssue.should_receive(:reorder_list).with(@viewed_user, @ordered_list)
    post_reorder
  end
end

# These intregrate the partial view
describe StuffToDoController, '#reorder for another user as an administrator with the js format' do
  def post_reorder
    post :reorder, :issue => @ordered_list, :user_id => @viewed_user.id, :format => 'js'
  end
  
  before(:each) do
    @current_user = mock_model(User, :admin? => true, :logged? => true, :language => :en)
    User.stub!(:current).and_return(@current_user)
    controller.stub!(:find_current_user).and_return(@current_user)
    @viewed_user = mock_model(User)
    User.stub!(:find).with(@viewed_user.id.to_s).and_return(@viewed_user)
    @ordered_list = ["500", "100", "300"]
    NextIssue.stub!(:doing_now).and_return([])
    NextIssue.stub!(:recommended).and_return([])
  end
  
  it 'should be successful' do
    post_reorder
    response.should be_success
  end
  
  it 'should be render the panes' do
    post_reorder
    response.should render_template('stuff_to_do/_panes')
  end
  
  it 'should reorder the Next Issues' do
    NextIssue.should_receive(:reorder_list).with(@viewed_user, @ordered_list)
    post_reorder
  end
  
  it 'should assign the doing now issues for the view' do
    post_reorder
    assigns[:doing_now].should_not be_nil
  end

  it 'should assign the recommended next issues for the view' do
    post_reorder
    assigns[:recommended].should_not be_nil
  end
end

describe StuffToDoController, '#reorder for another user as a user' do
  def post_reorder
    post :reorder, :user_id => @viewed_user.id
  end
  
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true, :language => :en)
    User.stub!(:current).and_return(@current_user)
    @viewed_user = mock_model(User)
  end

  it 'should not be successful' do
    post_reorder
    response.should_not be_success
  end
  
  it 'should return a 403 status code' do
    post_reorder
    response.code.should eql("403")
  end
  
  it 'should display the standard unauthorized page'
end

describe StuffToDoController, '#reorder with an unauthenticated user' do
  it 'should not be successful' do
    post :reorder
    response.should_not be_success
  end
  
  it 'should return a 403 status code' do
    post :reorder
    response.code.should eql("403")
  end
  
  it 'should display the standard unauthorized page'
end

describe StuffToDoController, '#filters_for_view (private)' do
  it 'should return a NextIssueFilter' do
    controller.send(:filters_for_view).should be_an_instance_of(NextIssueFilter)
  end

  it 'should include all the Users in users' do
    @user1 = mock_model(User)
    @user2 = mock_model(User)
    users = [@user1, @user2]
    User.should_receive(:active).and_return(users)

    filters = controller.send(:filters_for_view)
    filters.users.should include(@user1)
    filters.users.should include(@user2)
  end

  it 'should include all the IssuePriorities in priorities' do
    @priority1 = mock_model(Enumeration)
    @priority2 = mock_model(Enumeration)
    priorities = [@priority1, @priority2]
    Enumeration.should_receive(:priorities).and_return(priorities)

    filters = controller.send(:filters_for_view)
    filters.priorities.should include(@priority1)
    filters.priorities.should include(@priority2)
  end

  it 'should include all the IssueStatuses in statuses' do
    @status1 = mock_model(IssueStatus)
    @status2 = mock_model(IssueStatus)
    statuses = [@status1, @status2]
    IssueStatus.should_receive(:find).with(:all).and_return(statuses)

    filters = controller.send(:filters_for_view)
    filters.statuses.should include(@status1)
    filters.statuses.should include(@status2)
  end

end

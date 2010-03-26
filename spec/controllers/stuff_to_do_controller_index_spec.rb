require File.dirname(__FILE__) + '/../spec_helper'

describe StuffToDoController, '#index' do
  include Redmine::I18n

  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true, :language => :en, :memberships => [])
    @current_user.stub!(:time_grid_issues).and_return(Issue)
    User.stub!(:current).and_return(@current_user)
    StuffToDo.stub!(:available)
    StuffToDo.stub!(:using_issues_as_items?).and_return(true)
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
    StuffToDo.should_receive(:doing_now).with(@current_user).and_return(stuff)
    get :index
    assigns[:doing_now].should have(5).things
  end

  it 'should set @recommended to the next 10 issues for the current user' do
    stuff = []
    10.times { stuff << mock('stuff') }
    StuffToDo.should_receive(:recommended).with(@current_user).and_return(stuff)
    get :index
    assigns[:recommended].should have(10).things
  end
  
  it 'should set @available to the assigned issues that are not next issues for the current user' do
    stuff = []
    6.times { stuff << mock('stuff') }
    StuffToDo.should_receive(:available).with(@current_user, @current_user ).and_return(stuff)
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

  def do_request
    get :index
  end
  
  it_should_behave_like 'get_time_grid_data'
end

describe StuffToDoController, '#index for another user as an administrator' do
  def get_index
    get :index, :user_id => @viewed_user.id
  end
  
  before(:each) do
    @current_user = mock_model(User, :admin? => true, :logged? => true, :language => :en)
    @current_user.stub!(:time_grid_issues).and_return(Issue)
    User.stub!(:current).and_return(@current_user)
    controller.stub!(:find_current_user).and_return(@current_user)
    @viewed_user = mock_model(User)
    User.stub!(:find).with(@viewed_user.id.to_s).and_return(@viewed_user)
    StuffToDo.stub!(:available)
    StuffToDo.stub!(:using_issues_as_items?).and_return(true)
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
    StuffToDo.should_receive(:doing_now).with(@viewed_user).and_return(stuff)
    get_index
    assigns[:doing_now].should have(5).things
  end

  it 'should set @recommended to the next 10 issues for the current user' do
    stuff = []
    10.times { stuff << mock('stuff') }
    StuffToDo.should_receive(:recommended).with(@viewed_user).and_return(stuff)
    get_index
    assigns[:recommended].should have(10).things
  end
  
  it 'should set @available to the assigned issues that are not next issues for the current user' do
    stuff = []
    6.times { stuff << mock('stuff') }
    StuffToDo.should_receive(:available).with(@viewed_user, @viewed_user).and_return(stuff)
    get_index
    assigns[:available].should have(6).things
  end

end

describe StuffToDoController, '#index for another user as a user' do
  def get_index
    get :index, :user_id => @viewed_user.id
  end
  
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true, :language => :en, :memberships => [], :anonymous? => false, :name => "A Test User", :projects => Project)
    @current_user.stub!(:time_grid_issues).and_return(Issue)
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


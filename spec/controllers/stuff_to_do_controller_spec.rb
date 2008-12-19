require File.dirname(__FILE__) + '/../spec_helper'

describe StuffToDoController, '#index' do
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true)
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
    NextIssue.should_receive(:available).with(@current_user).and_return(stuff)
    get :index
    assigns[:available].should have(6).things
  end

end

describe StuffToDoController, '#index for another user as an administrator' do
  def get_index
    get :index, :user_id => @viewed_user.id
  end
  
  before(:each) do
    @current_user = mock_model(User, :admin? => true, :logged? => true)
    User.stub!(:current).and_return(@current_user)
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
    NextIssue.should_receive(:available).with(@viewed_user).and_return(stuff)
    get_index
    assigns[:available].should have(6).things
  end

end

# TODO: Test unauthenticated

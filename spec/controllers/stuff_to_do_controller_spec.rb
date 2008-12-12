require File.dirname(__FILE__) + '/../spec_helper'

describe StuffToDoController, '#index' do
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true)
    User.stub!(:current).and_return(@current_user)
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
    NextIssue.should_receive(:find).with(:all, { :conditions => ['user_id = ?', @current_user.id], :limit => 5, :order => 'position ASC' }).and_return(stuff)
    get :index
    assigns[:doing_now].should have(5).things
  end
  
end

# TODO: Test unauthenticated

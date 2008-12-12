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

end

# TODO: Test unauthenticated

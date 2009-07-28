require File.dirname(__FILE__) + '/../spec_helper'

describe StuffToDoController, '#add_to_time_grid' do
  include Redmine::I18n
  integrate_views
  
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true, :language => :en, :memberships => [], :anonymous? => false, :name => "A Test User", :projects => Project)
    User.stub!(:current).and_return(@current_user)
  end

  def do_request
    post :add_to_time_grid, {}
  end
  
  it_should_behave_like 'get_time_grid_data'

  it 'should add the issue_id to the issues list'

  it 'should render the time_grid template'
end


describe StuffToDoController, '#add_to_time_grid with an unauthenticated user' do
  it 'should not be successful' do
    post :add_to_time_grid, {}
    response.should_not be_success
  end
  
  it 'should return a 403 status code' do
    post :add_to_time_grid, {}
    response.code.should eql("403")
  end
  
  it 'should display the standard unauthorized page'
end



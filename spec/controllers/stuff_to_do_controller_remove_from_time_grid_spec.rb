require File.dirname(__FILE__) + '/../spec_helper'

describe StuffToDoController, '#remove_from_time_grid' do
  include Redmine::I18n
  integrate_views
  
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true, :language => :en, :memberships => [], :anonymous? => false, :name => "A Test User", :projects => Project)
    @current_user.stub!(:time_grid_issues).and_return(Issue)
    User.stub!(:current).and_return(@current_user)
  end

  def do_request
    post :remove_from_time_grid, {}
  end
  
  it_should_behave_like 'get_time_grid_data'

  it "should remove the issue_id from the user's time grid issues" do
    issue101 = mock_model(Issue, :id => 101)
    Issue.should_receive(:find_by_id).with('101').and_return(issue101)
    Issue.should_receive(:delete).with(issue101).and_return(true)
    
    post :remove_from_time_grid, {:issue_id => '101'}
  end

  it "should not remove anything if the issue_id isn't assigned to the user" do
    issue101 = mock_model(Issue, :id => 101)
    Issue.should_receive(:find_by_id).with('101').and_return(nil)
    Issue.should_not_receive(:delete)
    
    post :remove_from_time_grid, {:issue_id => '101'}
  end

  it 'should render the time_grid partial for js' do
    post :remove_from_time_grid, {:format => 'js'}
    response.should render_template('_time_grid')
  end
end


describe StuffToDoController, '#remove_from_time_grid with an unauthenticated user' do
  it 'should not be successful' do
    post :remove_from_time_grid, {}
    response.should_not be_success
  end
  
  it 'should return a 403 status code' do
    post :remove_from_time_grid, {}
    response.code.should eql("403")
  end
  
  it 'should display the standard unauthorized page'
end



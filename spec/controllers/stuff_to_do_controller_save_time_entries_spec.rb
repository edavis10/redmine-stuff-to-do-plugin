require File.dirname(__FILE__) + '/../spec_helper'

describe StuffToDoController, '#save_time_entries' do
  include Redmine::I18n
  integrate_views
  
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true, :language => :en, :memberships => [], :anonymous? => false, :name => "A Test User", :projects => Project, :allowed_to? => true)
    @current_user.stub!(:time_grid_issues).and_return(Issue)
    User.stub!(:current).and_return(@current_user)

    @project = mock_model(Project)
    @issue = mock('issue', :project => @project)
  end

  def do_request(params={})
    post :save_time_entry, {:format => 'js', :time_entry => []}.merge(params)
  end

  def make_time_entry_hash
    {:comments => 'Test comment', :issue_id => '100', :activity_id => '1', :spent_on => '2009-08-05', :hours => '1'}
  end

  def make_time_entry_mock(entry)
    TimeEntry.should_receive(:new).with(entry.stringify_keys).and_return do
      te = mock_model(TimeEntry)
      te.stub!(:issue).and_return(@issue) # So it can get the project
      te.should_receive(:project=).with(@project)
      te.stub!(:project).and_return(@project)
      te.should_receive(:user=).with(User.current)
      te.stub!(:comments).and_return(entry[:comments])
      yield te if block_given?
      te
    end
  end

  describe 'with a successful save' do
    before(:each) do
      controller.stub!(:save_time_entry_from_time_grid).and_return(true)
    end
    
    it_should_behave_like 'get_time_grid_data'
  end
  
  describe 'with a failed save' do
    it 'should render the error messages as a string' do
      do_request
      response.should_not be_success
      response.body.should match(/project/i)
      response.body.should match(/activity/i)
      response.body.should match(/comment/i)
      response.body.should match(/date/i)
      response.body.should match(/hours/i)
    end
  end
end

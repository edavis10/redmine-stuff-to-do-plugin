require File.dirname(__FILE__) + '/../spec_helper'

describe StuffToDoController, '#save_time_entries' do
  include Redmine::I18n
  integrate_views
  
  before(:each) do
    @current_user = mock_model(User, :admin? => false, :logged? => true, :language => :en, :memberships => [], :anonymous? => false, :name => "A Test User", :projects => Project, :allowed_to? => true)
    User.stub!(:current).and_return(@current_user)

    @project = mock_model(Project)
    @issue = mock('issue', :project => @project)

    TimeEntry.should_receive(:new).with(no_args).and_return do
      te = mock_model(TimeEntry,
                      :issue_id => nil,
                      :issue => nil,
                      :spent_on => nil,
                      :hours => nil,
                      :comments => nil,
                      :activity_id => nil,
                      :custom_field_values => [])
      te.errors.stub!(:[])
      te
    end
  end

  def do_request(params={})
    post :save_time_entries, {:format => 'js', :time_entry => []}.merge(params)
  end

  it_should_behave_like 'get_time_grid_data'

  it 'should save each time entry' do

    @time_entry1 = {:comments => '', :issue_id => '100', :activity_id => '1', :spent_on => '2009-08-05', :hours => '1'}
    @time_entry2 = {:comments => '', :issue_id => '101', :activity_id => '1', :spent_on => '2009-08-05', :hours => '2'}
    @time_entry3 = {:comments => '', :issue_id => '102', :activity_id => '1', :spent_on => '2009-08-05', :hours => '3'}
    @time_entry4 = {:comments => '', :issue_id => '103', :activity_id => '1', :spent_on => '2009-08-05', :hours => '4'}
    time_entries = [@time_entry1, @time_entry2, @time_entry3, @time_entry4]
    
    time_entries.each do |entry|
      TimeEntry.should_receive(:new).with(entry.stringify_keys).and_return do
        te = mock_model(TimeEntry)
        te.stub!(:issue).and_return(@issue) # So it can get the project
        te.should_receive(:project=).with(@project)
        te.stub!(:project).and_return(@project)
        te.should_receive(:user=).with(User.current)
        te.should_receive(:save).and_return(true)
        te
      end
    end

    do_request(:time_entry => time_entries)
  end

  it 'should check that the current user has permission to log time' do
    User.current.should_receive(:allowed_to?).with(:log_time, anything).and_return(false)
    @time_entry1 = {:comments => '', :issue_id => '100', :activity_id => '1', :spent_on => '2009-08-05', :hours => '1'}
      TimeEntry.should_receive(:new).with(@time_entry1.stringify_keys).and_return do
        te = mock_model(TimeEntry)
        te.stub!(:issue).and_return(@issue) # So it can get the project
        te.should_receive(:project=).with(@project)
        te.stub!(:project).and_return(@project)
        te.should_receive(:user=).with(User.current)
        te.should_not_receive(:save)
        te
      end
    
    do_request(:time_entry => [@time_entry1])
  end

  it 'should set the notice flash messaages to the number of saved time entries' do
    @time_entry1 = {:comments => '', :issue_id => '100', :activity_id => '1', :spent_on => '2009-08-05', :hours => '1'}
      TimeEntry.should_receive(:new).with(@time_entry1.stringify_keys).and_return do
        te = mock_model(TimeEntry)
        te.stub!(:issue).and_return(@issue) # So it can get the project
        te.should_receive(:project=).with(@project)
        te.stub!(:project).and_return(@project)
        te.should_receive(:user=).with(User.current)
        te.should_receive(:save).and_return(true)
        te
      end
    
    do_request(:time_entry => [@time_entry1])
    flash[:time_grid_notice].should eql('1 time entries saved.')
  end

  it 'should set the error flash messaages to the number of unsaved time entries' do
    @time_entry1 = {:comments => '', :issue_id => '100', :activity_id => '1', :spent_on => '2009-08-05', :hours => '1'}
      TimeEntry.should_receive(:new).with(@time_entry1.stringify_keys).and_return do
        te = mock_model(TimeEntry)
        te.stub!(:issue).and_return(@issue) # So it can get the project
        te.should_receive(:project=).with(@project)
        te.stub!(:project).and_return(@project)
        te.should_receive(:user=).with(User.current)
        te.should_receive(:save).and_return(false)
        te
      end
    
    do_request(:time_entry => [@time_entry1])
    flash[:time_grid_error].should eql('1 time entries could not be saved.')
  end

  it 'should render the time_grid partial for js' do
    do_request
    response.should render_template('_time_grid')
  end
end


describe StuffToDoController, '#save_time_entries with an unauthenticated user' do
  it 'should not be successful' do
    post :save_time_entries, {:format => 'js'}
    response.should_not be_success
  end
  
  it 'should return a 403 status code' do
    post :save_time_entrie, {:format => 'js'}
    response.code.should eql("403")
  end
  
  it 'should display the standard unauthorized page'
end



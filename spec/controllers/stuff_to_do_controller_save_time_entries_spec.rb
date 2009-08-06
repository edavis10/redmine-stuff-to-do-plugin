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

  def make_time_entry_hash
    {:comments => '', :issue_id => '100', :activity_id => '1', :spent_on => '2009-08-05', :hours => '1'}
  end

  def make_time_entry_mock(entry)
    TimeEntry.should_receive(:new).with(entry.stringify_keys).and_return do
      te = mock_model(TimeEntry)
      te.stub!(:issue).and_return(@issue) # So it can get the project
      te.should_receive(:project=).with(@project)
      te.stub!(:project).and_return(@project)
      te.should_receive(:user=).with(User.current)
      yield te if block_given?
      te
    end
  end
  
  it_should_behave_like 'get_time_grid_data'

  it 'should save each time entry' do
    time_entries = [make_time_entry_hash, make_time_entry_hash, make_time_entry_hash, make_time_entry_hash]

    time_entries.each do |entry|
      make_time_entry_mock(entry) do |time_entry|
        time_entry.should_receive(:save).and_return(true)
      end
    end      

    do_request(:time_entry => time_entries)
  end

  it 'should check that the current user has permission to log time' do
    User.current.should_receive(:allowed_to?).with(:log_time, anything).at_least(:twice).and_return(false)
    time_entries = [make_time_entry_hash, make_time_entry_hash]

    time_entries.each do |entry|
      make_time_entry_mock(entry) do |time_entry|
        time_entry.should_not_receive(:save)
      end
    end
      
    do_request(:time_entry => time_entries)
  end

  it 'should set the notice flash messaages to the number of saved time entries' do
    time_entries = [make_time_entry_hash, make_time_entry_hash]

    time_entries.each do |entry|
      make_time_entry_mock(entry) do |time_entry|
        time_entry.should_receive(:save).and_return(true)
      end
    end

    do_request(:time_entry => time_entries)
    flash[:time_grid_notice].should eql('2 time entries saved.')
  end

  it 'should set the error flash messaages to the number of unsaved time entries' do
    time_entries = [make_time_entry_hash, make_time_entry_hash]

    time_entries.each do |entry|
      make_time_entry_mock(entry) do |time_entry|
        time_entry.should_receive(:save).and_return(false)
      end
    end
    
    do_request(:time_entry => time_entries)
    flash[:time_grid_error].should eql('2 time entries could not be saved.')
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



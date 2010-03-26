require File.dirname(__FILE__) + '/../spec_helper'

describe StuffToDoController, '#filters_for_view (private)' do
  it 'should return a StuffToDoFilter' do
    controller.send(:filters_for_view).should be_an_instance_of(StuffToDoFilter)
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
    @priority1 = mock_model(IssuePriority)
    @priority2 = mock_model(IssuePriority)
    priorities = [@priority1, @priority2]
    IssuePriority.should_receive(:all).and_return(priorities)

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

describe StuffToDoController, '#save_time_entry_from_time_grid (private)' do
  before(:each) do
    @user = mock_model(User)
    User.stub!(:current).and_return(@user)
    @project = mock_model(Project)
    User.current.stub!(:allowed_to?).and_return(true)
    
    @time_entry = TimeEntry.new(:comments => 'A comment for validation')
    @time_entry.stub!(:project).and_return(@project)
    @time_entry.stub!(:valid?).and_return(true)
    @time_entry.stub!(:save).and_return(true)
  end
  
  it 'should check if a TimeEntry is valid' do
    @time_entry.should_receive(:valid?).and_return(true)
    controller.send(:save_time_entry_from_time_grid, @time_entry)
  end

  it 'should add an error if comments are blank' do
    @time_entry.stub!(:valid?).and_return(true)
    @time_entry.should_receive(:comments).at_least(:once).and_return('')
    controller.send(:save_time_entry_from_time_grid, @time_entry)

    @time_entry.errors.should have(1).error_on(:comments)
  end

  it 'should check if the user is allowed to log_time to the project' do
    User.current.should_receive(:allowed_to?).with(:log_time, @project).and_return(true)
    @time_entry.should_receive(:project).and_return(@project)
    @time_entry.should_receive(:save).and_return(true)
    
    controller.send(:save_time_entry_from_time_grid, @time_entry)
  end

  it 'should save a valid TimeEntry' do
    @time_entry.should_receive(:save).and_return(true)
    controller.send(:save_time_entry_from_time_grid, @time_entry)
  end

end

require File.dirname(__FILE__) + '/../spec_helper'

module StuffToDoSpecHelper
  def issue_factory(number, fields = { })
    issues = []
    number.times do |issue_number|
      issues << mock_model(Issue, { :id => issue_number }.merge(fields))
    end
    
    return issues
  end
  
  def next_issues_from_issues(issues, number_of_next_issues = nil)
    number_of_next_issues ||= issues.size
    
    next_issues = []
    issues.each do |issue|
      next if next_issues.size >= number_of_next_issues
      next_issues << mock_model(StuffToDo, :stuff => issue)
    end
    
    return next_issues
  end
end

describe StuffToDo, 'associations' do
  it 'should belong to a polymorphic "stuff"' do
    StuffToDo.should have_association(:stuff, :belongs_to)
  end

  it 'should belong to a user' do
    StuffToDo.should have_association(:user, :belongs_to)
  end
end

describe StuffToDo, '#available with no filter' do

  before(:each) do
    @user = mock_model(User)
  end

  it 'should find nothing' do
    StuffToDo.available(@user).should be_empty
  end
end

describe StuffToDo, '#available for user' do
  include StuffToDoSpecHelper

  before(:each) do
    @user = mock_model(User)
    @find_options = { :conditions => ['assigned_to_id = ? AND issue_statuses.is_closed = ?',@user.id, false ], :include => :status, :order => 'created_on DESC'}
  end
  
  it 'should find all assigned issues for the user' do
    issues = issue_factory(10, { :assigned_to => @user })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    StuffToDo.available(@user, :user => @user).should eql(issues)
  end

  it 'should not include issues that are StuffToDos' do
    issues = issue_factory(10, { :assigned_to => @user })
    # Add in half the issues as StuffToDos
    next_issues = next_issues_from_issues(issues, issues.size / 2)
    
    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    StuffToDo.should_receive(:find).with(:all, { :conditions => { :user_id => @user.id }}).and_return(next_issues)
    StuffToDo.available(@user, :user => @user).should eql(issues - next_issues.collect(&:stuff))
  end
  
  it 'should only include open issues' do
    issues = issue_factory(10, { :assigned_to => @user })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    available = StuffToDo.available(@user, :user => @user)
    available.should have(10).items
    available.should eql(issues)
  end
end

describe StuffToDo, '#available for status' do
  include StuffToDoSpecHelper

  before(:each) do
    @user = mock_model(User)
    @status = mock_model(IssueStatus)
    @find_options = { :conditions => ['issue_statuses.id = (?) AND issue_statuses.is_closed = ?', @status.id, false ], :include => :status, :order => 'created_on DESC'}
  end
  
  it 'should find all issues with the status' do
    issues = issue_factory(10, { :status => @status })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    StuffToDo.available(@user, :status => @status).should eql(issues)
  end

  it 'should not include issues that are StuffToDos' do
    issues = issue_factory(10, { :status => @status })
    # Add in half the issues as StuffToDos
    next_issues = next_issues_from_issues(issues, issues.size / 2)
    
    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    StuffToDo.should_receive(:find).with(:all, { :conditions => { :user_id => @user.id }}).and_return(next_issues)
    StuffToDo.available(@user, :status => @status).should eql(issues - next_issues.collect(&:stuff))
  end
  
  it 'should only include open issues' do
    issues = issue_factory(10, { :status => @status })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    available = StuffToDo.available(@user, :status => @status)
    available.should have(10).items
    available.should eql(issues)
  end
end

describe StuffToDo, '#available for priority' do
  include StuffToDoSpecHelper

  before(:each) do
    @user = mock_model(User)
    @priority = mock_model(Enumeration, :opt => 'IPRI')
    @find_options = { :conditions => ['enumerations.id = (?) AND issue_statuses.is_closed = ?', @priority.id, false ], :include => [:status, :priority], :order => 'created_on DESC'}
  end

  it 'should find all issues with the priority' do
    issues = issue_factory(10, { :priority => @priority })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    StuffToDo.available(@user, :priority => @priority).should eql(issues)
  end

  it 'should not include issues that are StuffToDos' do
    issues = issue_factory(10, { :priority => @priority })
    # Add in half the issues as StuffToDos
    next_issues = next_issues_from_issues(issues, issues.size / 2)
    
    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    StuffToDo.should_receive(:find).with(:all, { :conditions => { :user_id => @user.id }}).and_return(next_issues)
    StuffToDo.available(@user, :priority => @priority).should eql(issues - next_issues.collect(&:stuff))
  end
  
  it 'should only include open issues' do
    issues = issue_factory(10, { :priority => @priority })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    available = StuffToDo.available(@user, :priority => @priority)
    available.should have(10).items
    available.should eql(issues)
  end
end

describe StuffToDo, '#closing_issue' do
  before(:each) do
    @issue = mock_model(Issue)
    @issue.stub!(:closed?).and_return(true)
  end
  
  it 'should do nothing if the issue is still open' do
    @issue.should_receive(:closed?).and_return(false)
    StuffToDo.closing_issue(@issue)
  end

  it 'should delete all StuffToDos for the closed issue' do
    next_issue_one = mock_model(StuffToDo, :stuff_id => @issue.id, :user_id => nil)
    next_issue_one.should_receive(:destroy).and_return(true)
    next_issue_two = mock_model(StuffToDo, :stuff_id => @issue.id, :user_id => nil)
    next_issue_two.should_receive(:destroy).and_return(true)
    next_issues = [next_issue_one, next_issue_two]
    StuffToDo.should_receive(:find).with(:all, { :conditions => { :stuff_id => @issue.id }}).and_return(next_issues)

    StuffToDo.closing_issue(@issue)
  end
end

describe StuffToDo, '#closing_issue' do
  before(:each) do
    @issue = mock_model(Issue)
    @issue.stub!(:closed?).and_return(true)

    @user = mock_model(User)
    @next_issue_one = mock_model(StuffToDo, :stuff_id => @issue.id, :user_id => @user.id)
    @next_issue_one.should_receive(:destroy).and_return(true)
    @next_issue_two = mock_model(StuffToDo, :stuff_id => @issue.id, :user_id => @user.id)
    @next_issue_two.should_receive(:destroy).and_return(true)
    @next_issues = [@next_issue_one, @next_issue_two]
    StuffToDo.stub!(:find).and_return(@next_issues)
    @number_of_next_issues = 4
    StuffToDo.stub!(:count).with(:conditions => { :user_id => @user.id }).and_return(@number_of_next_issues)
  end
  
  it 'should deliver a StuffToDoMailer notification if the StuffToDos are below the threshold' do
    Setting.should_receive(:plugin_stuff_to_do_plugin).and_return({'threshold' => @number_of_next_issues + 1 })
    User.should_receive(:find_by_id).with(@user.id).and_return(@user)
    StuffToDoMailer.should_receive(:deliver_recommended_below_threshold).with(@user, 4)
    StuffToDo.closing_issue(@issue)
  end

  it 'should deliver a StuffToDoMailer notification if the StuffToDos are at the threshold' do
    Setting.should_receive(:plugin_stuff_to_do_plugin).and_return({'threshold' => @number_of_next_issues })
    User.should_receive(:find_by_id).with(@user.id).and_return(@user)
    StuffToDoMailer.should_receive(:deliver_recommended_below_threshold).with(@user, 4)
    StuffToDo.closing_issue(@issue)
  end

  it 'should not deliver any StuffToDoMailer notification if the StuffToDos are above the threshold' do
    Setting.should_receive(:plugin_stuff_to_do_plugin).and_return({'threshold' => @number_of_next_issues - 1 })
    StuffToDoMailer.should_not_receive(:deliver_recommended_below_threshold)
    StuffToDo.closing_issue(@issue)
  end
  
end

describe StuffToDo, '#remove_stale_assignments' do
  it 'should destroy all StuffToDos for an issue except for the currently assigned user' do
    @user = mock_model(User)
    @user2 = mock_model(User)
    @user3 = mock_model(User)
    
    @issue = mock_model(Issue, :assigned_to_id => @user.id)

    @next_issue_one = mock_model(StuffToDo, :stuff_id => @issue.id, :user_id => @user2.id)
    @next_issue_two = mock_model(StuffToDo, :stuff_id => @issue.id, :user_id => @user3.id)
    @next_issues = [@next_issue_one, @next_issue_two]
    
    StuffToDo.should_receive(:destroy_all).with(['stuff_id = (?) AND user_id NOT IN (?)', @issue.id, @issue.assigned_to_id]).and_return(@next_issues)

    StuffToDo.remove_stale_assignments(@issue)
  end

  it 'should destroy all StuffToDos for an issue if the currently assigned user is blank' do
    @user = mock_model(User)
    @user2 = mock_model(User)
    @user3 = mock_model(User)
    
    @issue = mock_model(Issue, :assigned_to_id => nil)

    @next_issue_one = mock_model(StuffToDo, :stuff_id => @issue.id, :user_id => @user2.id)
    @next_issue_two = mock_model(StuffToDo, :stuff_id => @issue.id, :user_id => @user3.id)
    @next_issues = [@next_issue_one, @next_issue_two]

    StuffToDo.should_receive(:destroy_all).with(['stuff_id = (?)', @issue.id]).and_return(@next_issues)

    StuffToDo.remove_stale_assignments(@issue)
  end

end


describe StuffToDo, '#reorder_list' do
  it 'should require a user_id' do
    lambda { 
      StuffToDo.reorder_list
    }.should raise_error
    
  end

  it 'should require an array of issue ids' do
    user = mock_model(User)
    lambda { 
      StuffToDo.reorder_list(user)
    }.should raise_error
  end
  
  it 'should find all the next issues' do
    user = mock_model(User)
    issue_ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    next_issues = []
    issue_ids.each do |id|
      next_issues << mock_model(StuffToDo, :stuff_id => id, :insert_at => true)
    end
    
    StuffToDo.should_receive(:find_all_by_user_id).with(user.id).and_return(next_issues)
    StuffToDo.reorder_list(user, issue_ids)
  end

  
  it 'should save the positions of the issues to the database' do
    user = mock_model(User)
    issue_ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    next_issues = []
    issue_ids.each_with_index do |id, array_position|
      next_issue = mock_model(StuffToDo, :stuff_id => id, :id => id)
      next_issue.should_receive(:insert_at).with(array_position + 1)
      next_issues << next_issue
    end
    
    StuffToDo.stub!(:find_all_by_user_id).with(user.id).and_return(next_issues)
    StuffToDo.reorder_list(user, issue_ids)
    
  end
  
  it 'should add new StuffToDo that are in the list but not in the database' do
    user = mock_model(User)
    issue_ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    next_issues = []
    issue_ids.each_with_index do |id, array_position|
      next_issues << mock_model(StuffToDo, :stuff_id => id, :insert_at => true) unless id == "820"
    end

    next_issue_for_820 = StuffToDo.new
    next_issue_for_820.should_receive(:stuff_id=).with(820)
    next_issue_for_820.should_receive(:user_id=).with(user.id)
    next_issue_for_820.should_receive(:save).and_return(true)
    position = issue_ids.index("820") + 1
    next_issue_for_820.should_receive(:insert_at).with(position)
    StuffToDo.should_receive(:new).and_return(next_issue_for_820)
    
    StuffToDo.stub!(:find_all_by_user_id).with(user.id).and_return(next_issues)
    StuffToDo.reorder_list(user, issue_ids)
  end
  
  it 'should destroy any StuffToDos that are not in the list' do
    user = mock_model(User)
    issue_ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    next_issues = []
    issue_ids.each_with_index do |id, array_position|
      next_issues << mock_model(StuffToDo, :stuff_id => id, :insert_at => true)
    end

    extra_next_issue = mock_model(StuffToDo, :stuff_id => 999)
    extra_next_issue.should_receive(:destroy).and_return(true)
    StuffToDo.should_receive(:find_by_user_id_and_stuff_id).with(user.id, extra_next_issue.stuff_id).and_return(extra_next_issue)
    next_issues << extra_next_issue
    
    StuffToDo.stub!(:find_all_by_user_id).with(user.id).and_return(next_issues)
    StuffToDo.reorder_list(user, issue_ids)

  end
  
  it 'should destroy all StuffToDos if the list is empty' do
    user = mock_model(User)
    issue_ids = nil
    next_issues = []

    extra_next_issue = mock_model(StuffToDo, :stuff_id => 999)
    extra_next_issue.should_receive(:destroy).and_return(true)
    StuffToDo.should_receive(:find_by_user_id_and_stuff_id).with(user.id, extra_next_issue.stuff_id).and_return(extra_next_issue)
    next_issues << extra_next_issue
    
    StuffToDo.stub!(:find_all_by_user_id).with(user.id).and_return(next_issues)
    StuffToDo.reorder_list(user, issue_ids)
    
  end
end

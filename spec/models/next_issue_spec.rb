require File.dirname(__FILE__) + '/../spec_helper'

module NextIssueSpecHelper
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
      next_issues << mock_model(NextIssue, :issue => issue)
    end
    
    return next_issues
  end
end

describe NextIssue, 'associations' do
  it 'should belong to an Issue' do
    NextIssue.should have_association(:issue, :belongs_to)
  end

  it 'should belong to a user' do
    NextIssue.should have_association(:user, :belongs_to)
  end
end

describe NextIssue, '#available with no filter' do

  before(:each) do
    @user = mock_model(User)
  end

  it 'should find nothing' do
    NextIssue.available(@user).should be_empty
  end
end

describe NextIssue, '#available for user' do
  include NextIssueSpecHelper

  before(:each) do
    @user = mock_model(User)
    @find_options = { :conditions => ['assigned_to_id = ? AND issue_statuses.is_closed = ?',@user.id, false ], :include => :status, :order => 'created_on DESC'}
  end
  
  it 'should find all assigned issues for the user' do
    issues = issue_factory(10, { :assigned_to => @user })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    NextIssue.available(@user, :user => @user).should eql(issues)
  end

  it 'should not include issues that are NextIssues' do
    issues = issue_factory(10, { :assigned_to => @user })
    # Add in half the issues as NextIssues
    next_issues = next_issues_from_issues(issues, issues.size / 2)
    
    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    NextIssue.should_receive(:find).with(:all, { :conditions => { :user_id => @user.id }}).and_return(next_issues)
    NextIssue.available(@user, :user => @user).should eql(issues - next_issues.collect(&:issue))
  end
  
  it 'should only include open issues' do
    issues = issue_factory(10, { :assigned_to => @user })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    available = NextIssue.available(@user, :user => @user)
    available.should have(10).items
    available.should eql(issues)
  end
end

describe NextIssue, '#available for status' do
  include NextIssueSpecHelper

  before(:each) do
    @user = mock_model(User)
    @status = mock_model(IssueStatus)
    @find_options = { :conditions => ['issue_statuses.id = (?) AND issue_statuses.is_closed = ?', @status.id, false ], :include => :status, :order => 'created_on DESC'}
  end
  
  it 'should find all issues with the status' do
    issues = issue_factory(10, { :status => @status })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    NextIssue.available(@user, :status => @status).should eql(issues)
  end

  it 'should not include issues that are NextIssues' do
    issues = issue_factory(10, { :status => @status })
    # Add in half the issues as NextIssues
    next_issues = next_issues_from_issues(issues, issues.size / 2)
    
    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    NextIssue.should_receive(:find).with(:all, { :conditions => { :user_id => @user.id }}).and_return(next_issues)
    NextIssue.available(@user, :status => @status).should eql(issues - next_issues.collect(&:issue))
  end
  
  it 'should only include open issues' do
    issues = issue_factory(10, { :status => @status })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    available = NextIssue.available(@user, :status => @status)
    available.should have(10).items
    available.should eql(issues)
  end
end

describe NextIssue, '#available for priority' do
  include NextIssueSpecHelper

  before(:each) do
    @user = mock_model(User)
    @priority = mock_model(Enumeration, :opt => 'IPRI')
    @find_options = { :conditions => ['enumerations.id = (?) AND issue_statuses.is_closed = ?', @priority.id, false ], :include => [:status, :priority], :order => 'created_on DESC'}
  end

  it 'should find all issues with the priority' do
    issues = issue_factory(10, { :priority => @priority })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    NextIssue.available(@user, :priority => @priority).should eql(issues)
  end

  it 'should not include issues that are NextIssues' do
    issues = issue_factory(10, { :priority => @priority })
    # Add in half the issues as NextIssues
    next_issues = next_issues_from_issues(issues, issues.size / 2)
    
    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    NextIssue.should_receive(:find).with(:all, { :conditions => { :user_id => @user.id }}).and_return(next_issues)
    NextIssue.available(@user, :priority => @priority).should eql(issues - next_issues.collect(&:issue))
  end
  
  it 'should only include open issues' do
    issues = issue_factory(10, { :priority => @priority })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    available = NextIssue.available(@user, :priority => @priority)
    available.should have(10).items
    available.should eql(issues)
  end
end

describe NextIssue, '#closing_issue' do
  before(:each) do
    @issue = mock_model(Issue)
    @issue.stub!(:closed?).and_return(true)
  end
  
  it 'should do nothing if the issue is still open' do
    @issue.should_receive(:closed?).and_return(false)
    NextIssue.closing_issue(@issue)
  end

  it 'should delete all NextIssues for the closed issue' do
    next_issue_one = mock_model(NextIssue, :issue_id => @issue.id, :user_id => nil)
    next_issue_one.should_receive(:destroy).and_return(true)
    next_issue_two = mock_model(NextIssue, :issue_id => @issue.id, :user_id => nil)
    next_issue_two.should_receive(:destroy).and_return(true)
    next_issues = [next_issue_one, next_issue_two]
    NextIssue.should_receive(:find).with(:all, { :conditions => { :issue_id => @issue.id }}).and_return(next_issues)

    NextIssue.closing_issue(@issue)
  end
end

describe NextIssue, '#closing_issue' do
  before(:each) do
    @issue = mock_model(Issue)
    @issue.stub!(:closed?).and_return(true)

    @user = mock_model(User)
    @next_issue_one = mock_model(NextIssue, :issue_id => @issue.id, :user_id => @user.id)
    @next_issue_one.should_receive(:destroy).and_return(true)
    @next_issue_two = mock_model(NextIssue, :issue_id => @issue.id, :user_id => @user.id)
    @next_issue_two.should_receive(:destroy).and_return(true)
    @next_issues = [@next_issue_one, @next_issue_two]
    NextIssue.stub!(:find).and_return(@next_issues)
    @number_of_next_issues = 4
    NextIssue.stub!(:count).with(:conditions => { :user_id => @user.id }).and_return(@number_of_next_issues)
  end
  
  it 'should deliver a NextIssueMailer notification if the NextIssues are below the threshold' do
    Setting.should_receive(:plugin_stuff_to_do_plugin).and_return({'threshold' => @number_of_next_issues + 1 })
    User.should_receive(:find_by_id).with(@user.id).and_return(@user)
    NextIssueMailer.should_receive(:deliver_recommended_below_threshold).with(@user, 4)
    NextIssue.closing_issue(@issue)
  end

  it 'should deliver a NextIssueMailer notification if the NextIssues are at the threshold' do
    Setting.should_receive(:plugin_stuff_to_do_plugin).and_return({'threshold' => @number_of_next_issues })
    User.should_receive(:find_by_id).with(@user.id).and_return(@user)
    NextIssueMailer.should_receive(:deliver_recommended_below_threshold).with(@user, 4)
    NextIssue.closing_issue(@issue)
  end

  it 'should not deliver any NextIssueMailer notification if the NextIssues are above the threshold' do
    Setting.should_receive(:plugin_stuff_to_do_plugin).and_return({'threshold' => @number_of_next_issues - 1 })
    NextIssueMailer.should_not_receive(:deliver_recommended_below_threshold)
    NextIssue.closing_issue(@issue)
  end
  
end

describe NextIssue, '#remove_stale_assignments' do
  it 'should destroy all NextIssues for an issue except for the currently assigned user' do
    @user = mock_model(User)
    @user2 = mock_model(User)
    @user3 = mock_model(User)
    
    @issue = mock_model(Issue, :assigned_to_id => @user.id)

    @next_issue_one = mock_model(NextIssue, :issue_id => @issue.id, :user_id => @user2.id)
    @next_issue_two = mock_model(NextIssue, :issue_id => @issue.id, :user_id => @user3.id)
    @next_issues = [@next_issue_one, @next_issue_two]
    
    NextIssue.should_receive(:destroy_all).with(['issue_id = (?) AND user_id NOT IN (?)', @issue.id, @issue.assigned_to_id]).and_return(@next_issues)

    NextIssue.remove_stale_assignments(@issue)
  end

  it 'should destroy all NextIssues for an issue if the currently assigned user is blank' do
    @user = mock_model(User)
    @user2 = mock_model(User)
    @user3 = mock_model(User)
    
    @issue = mock_model(Issue, :assigned_to_id => nil)

    @next_issue_one = mock_model(NextIssue, :issue_id => @issue.id, :user_id => @user2.id)
    @next_issue_two = mock_model(NextIssue, :issue_id => @issue.id, :user_id => @user3.id)
    @next_issues = [@next_issue_one, @next_issue_two]

    NextIssue.should_receive(:destroy_all).with(['issue_id = (?)', @issue.id]).and_return(@next_issues)

    NextIssue.remove_stale_assignments(@issue)
  end

end


describe NextIssue, '#reorder_list' do
  it 'should require a user_id' do
    lambda { 
      NextIssue.reorder_list
    }.should raise_error
    
  end

  it 'should require an array of issue ids' do
    user = mock_model(User)
    lambda { 
      NextIssue.reorder_list(user)
    }.should raise_error
  end
  
  it 'should find all the next issues' do
    user = mock_model(User)
    issue_ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    next_issues = []
    issue_ids.each do |id|
      next_issues << mock_model(NextIssue, :issue_id => id, :insert_at => true)
    end
    
    NextIssue.should_receive(:find_all_by_user_id).with(user.id).and_return(next_issues)
    NextIssue.reorder_list(user, issue_ids)
  end

  
  it 'should save the positions of the issues to the database' do
    user = mock_model(User)
    issue_ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    next_issues = []
    issue_ids.each_with_index do |id, array_position|
      next_issue = mock_model(NextIssue, :issue_id => id, :id => id)
      next_issue.should_receive(:insert_at).with(array_position + 1)
      next_issues << next_issue
    end
    
    NextIssue.stub!(:find_all_by_user_id).with(user.id).and_return(next_issues)
    NextIssue.reorder_list(user, issue_ids)
    
  end
  
  it 'should add new NextIssue that are in the list but not in the database' do
    user = mock_model(User)
    issue_ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    next_issues = []
    issue_ids.each_with_index do |id, array_position|
      next_issues << mock_model(NextIssue, :issue_id => id, :insert_at => true) unless id == "820"
    end

    next_issue_for_820 = NextIssue.new
    next_issue_for_820.should_receive(:issue_id=).with(820)
    next_issue_for_820.should_receive(:user_id=).with(user.id)
    next_issue_for_820.should_receive(:save).and_return(true)
    position = issue_ids.index("820") + 1
    next_issue_for_820.should_receive(:insert_at).with(position)
    NextIssue.should_receive(:new).and_return(next_issue_for_820)
    
    NextIssue.stub!(:find_all_by_user_id).with(user.id).and_return(next_issues)
    NextIssue.reorder_list(user, issue_ids)
  end
  
  it 'should destroy any NextIssues that are not in the list' do
    user = mock_model(User)
    issue_ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    next_issues = []
    issue_ids.each_with_index do |id, array_position|
      next_issues << mock_model(NextIssue, :issue_id => id, :insert_at => true)
    end

    extra_next_issue = mock_model(NextIssue, :issue_id => 999)
    extra_next_issue.should_receive(:destroy).and_return(true)
    NextIssue.should_receive(:find_by_user_id_and_issue_id).with(user.id, extra_next_issue.issue_id).and_return(extra_next_issue)
    next_issues << extra_next_issue
    
    NextIssue.stub!(:find_all_by_user_id).with(user.id).and_return(next_issues)
    NextIssue.reorder_list(user, issue_ids)

  end
  
  it 'should destroy all NextIssues if the list is empty' do
    user = mock_model(User)
    issue_ids = nil
    next_issues = []

    extra_next_issue = mock_model(NextIssue, :issue_id => 999)
    extra_next_issue.should_receive(:destroy).and_return(true)
    NextIssue.should_receive(:find_by_user_id_and_issue_id).with(user.id, extra_next_issue.issue_id).and_return(extra_next_issue)
    next_issues << extra_next_issue
    
    NextIssue.stub!(:find_all_by_user_id).with(user.id).and_return(next_issues)
    NextIssue.reorder_list(user, issue_ids)
    
  end
end

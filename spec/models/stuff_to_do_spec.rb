require File.dirname(__FILE__) + '/../spec_helper'

module StuffToDoSpecHelper
  def issue_factory(number, fields = { })
    issues = []
    number.times do |issue_number|
      issues << mock_model(Issue, { :id => issue_number }.merge(fields))
    end
    
    return issues
  end

  def project_factory(number, fields = {})
    projects = []
    number.times do |project_number|
      projects << mock_model(Project, { :id => project_number }.merge(fields))
    end
    
    return projects
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
    @find_options = { :conditions => ['1=1 AND (issue_statuses.is_closed = ?) AND (projects.status = ?) AND (assigned_to_id = ?)',false, 1, @user.id ], :include => [:status, :priority, :project], :order => 'issues.created_on DESC'}
  end
  
  it 'should find all assigned issues for the user' do
    issues = issue_factory(10, { :assigned_to => @user })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    StuffToDo.available(@user, @user).should eql(issues)
  end

  it 'should not include issues that are StuffToDos' do
    issues = issue_factory(10, { :assigned_to => @user })
    # Add in half the issues as StuffToDos
    next_issues = next_issues_from_issues(issues, issues.size / 2)
    
    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    StuffToDo.should_receive(:find).with(:all, { :conditions => { :user_id => @user.id }}).and_return(next_issues)
    StuffToDo.available(@user, @user).should eql(issues - next_issues.collect(&:stuff))
  end
  
  it 'should only include open issues' do
    issues = issue_factory(10, { :assigned_to => @user })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    available = StuffToDo.available(@user, @user)
    available.should have(10).items
    available.should eql(issues)
  end
end

describe StuffToDo, '#available for status' do
  include StuffToDoSpecHelper

  before(:each) do
    @user = mock_model(User)
    @status = mock_model(IssueStatus)
    @find_options = { :conditions => ['1=1 AND (issue_statuses.is_closed = ?) AND (projects.status = ?) AND (issue_statuses.id = (?))', false, 1, @status.id ], :include => [:status, :priority, :project], :order => 'issues.created_on DESC'}
  end
  
  it 'should find all issues with the status' do
    issues = issue_factory(10, { :status => @status })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    StuffToDo.available(@user, @status).should eql(issues)
  end

  it 'should not include issues that are StuffToDos' do
    issues = issue_factory(10, { :status => @status })
    # Add in half the issues as StuffToDos
    next_issues = next_issues_from_issues(issues, issues.size / 2)
    
    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    StuffToDo.should_receive(:find).with(:all, { :conditions => { :user_id => @user.id }}).and_return(next_issues)
    StuffToDo.available(@user, @status).should eql(issues - next_issues.collect(&:stuff))
  end
  
  it 'should only include open issues' do
    issues = issue_factory(10, { :status => @status })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    available = StuffToDo.available(@user, @status)
    available.should have(10).items
    available.should eql(issues)
  end
end

describe StuffToDo, '#available for priority' do
  include StuffToDoSpecHelper

  before(:each) do
    @user = mock_model(User)
    @priority = mock_model(Enumeration, :opt => 'IPRI')
    @find_options = { :conditions => ['1=1 AND (issue_statuses.is_closed = ?) AND (projects.status = ?) AND (enumerations.id = (?))', false, 1, @priority.id ], :include => [:status, :priority, :project], :order => 'issues.created_on DESC'}
  end

  it 'should find all issues with the priority' do
    issues = issue_factory(10, { :priority => @priority })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    StuffToDo.available(@user, @priority).should eql(issues)
  end

  it 'should not include issues that are StuffToDos' do
    issues = issue_factory(10, { :priority => @priority })
    # Add in half the issues as StuffToDos
    next_issues = next_issues_from_issues(issues, issues.size / 2)
    
    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    StuffToDo.should_receive(:find).with(:all, { :conditions => { :user_id => @user.id }}).and_return(next_issues)
    StuffToDo.available(@user, @priority).should eql(issues - next_issues.collect(&:stuff))
  end
  
  it 'should only include open issues' do
    issues = issue_factory(10, { :priority => @priority })

    Issue.should_receive(:find).with(:all, @find_options).and_return(issues)
    available = StuffToDo.available(@user, @priority)
    available.should have(10).items
    available.should eql(issues)
  end
end

describe StuffToDo, '#available for project' do
  include StuffToDoSpecHelper

  before(:each) do
    @user = mock_model(User)
    @priority = mock_model(Enumeration, :opt => 'IPRI')
  end

  it 'should find all active projects visible to the user' do
    issues = issue_factory(10, { :priority => @priority })
    projects = project_factory(10)
    projects.should_receive(:sort).and_return(projects) # No need to test the sort order
    
    Project.should_receive(:active).and_return(Project)
    Project.should_receive(:visible).and_return(projects)

    StuffToDo.available(@user, Project.new).should eql(projects)
  end

  it 'should not include projects that are StuffToDos already' do
    projects = project_factory(10)
    projects.stub!(:sort).and_return(projects) # No need to test the sort order
    # Add in half the issues as StuffToDos
    stuff_to_dos = next_issues_from_issues(projects, projects.size / 2)

    Project.should_receive(:active).and_return(Project)
    Project.should_receive(:visible).and_return(projects)
    StuffToDo.should_receive(:find).with(:all, { :conditions => { :user_id => @user.id }}).and_return(stuff_to_dos)
    
    StuffToDo.available(@user, Project.new).should eql(projects - stuff_to_dos.collect(&:stuff))
  end
end

describe StuffToDo, '#remove_associations_to' do
  before(:each) do
    @issue = mock_model(Issue)
    @issue.stub!(:closed?).and_return(true)
    @project = mock_model(Project)
    @project.stub!(:active).and_return(false)
  end
  
  it 'should delete all StuffToDos for a closed issue' do
    next_issue_one = mock_model(StuffToDo, :stuff_id => @issue.id, :user_id => nil)
    next_issue_one.should_receive(:destroy).and_return(true)
    next_issue_two = mock_model(StuffToDo, :stuff_id => @issue.id, :user_id => nil)
    next_issue_two.should_receive(:destroy).and_return(true)
    next_issues = [next_issue_one, next_issue_two]
    @issue.should_receive(:stuff_to_dos).and_return(next_issues)

    StuffToDo.remove_associations_to(@issue)
  end

  it 'should delete all StuffToDos for a archived project' do
    next_issue_one = mock_model(StuffToDo, :stuff_id => @project.id, :user_id => nil)
    next_issue_one.should_receive(:destroy).and_return(true)
    next_issue_two = mock_model(StuffToDo, :stuff_id => @project.id, :user_id => nil)
    next_issue_two.should_receive(:destroy).and_return(true)
    next_issues = [next_issue_one, next_issue_two]
    @project.should_receive(:stuff_to_dos).and_return(next_issues)

    StuffToDo.remove_associations_to(@project)
  end
end

describe StuffToDo, '#remove_associations_to' do
  before(:each) do
    @issue = mock_model(Issue)
    @issue.stub!(:closed?).and_return(true)

    @user = mock_model(User)
    @next_issue_one = mock_model(StuffToDo, :stuff_id => @issue.id, :user_id => @user.id)
    @next_issue_one.should_receive(:destroy).and_return(true)
    @next_issue_two = mock_model(StuffToDo, :stuff_id => @issue.id, :user_id => @user.id)
    @next_issue_two.should_receive(:destroy).and_return(true)
    @next_issues = [@next_issue_one, @next_issue_two]
    @issue.stub!(:stuff_to_dos).and_return(@next_issues)
    @number_of_next_issues = 4
    StuffToDo.stub!(:count).with(:conditions => { :user_id => @user.id }).and_return(@number_of_next_issues)
  end
  
  it 'should deliver a StuffToDoMailer notification if the StuffToDos are below the threshold' do
    Setting.should_receive(:plugin_stuff_to_do_plugin).and_return({'threshold' => @number_of_next_issues + 1 })
    User.should_receive(:find_by_id).with(@user.id).and_return(@user)
    StuffToDoMailer.should_receive(:deliver_recommended_below_threshold).with(@user, 4)
    StuffToDo.remove_associations_to(@issue)
  end

  it 'should deliver a StuffToDoMailer notification if the StuffToDos are at the threshold' do
    Setting.should_receive(:plugin_stuff_to_do_plugin).and_return({'threshold' => @number_of_next_issues })
    User.should_receive(:find_by_id).with(@user.id).and_return(@user)
    StuffToDoMailer.should_receive(:deliver_recommended_below_threshold).with(@user, 4)
    StuffToDo.remove_associations_to(@issue)
  end

  it 'should not deliver any StuffToDoMailer notification if the StuffToDos are above the threshold' do
    Setting.should_receive(:plugin_stuff_to_do_plugin).and_return({'threshold' => @number_of_next_issues - 1 })
    StuffToDoMailer.should_not_receive(:deliver_recommended_below_threshold)
    StuffToDo.remove_associations_to(@issue)
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

  it 'should require an array of  ids' do
    user = mock_model(User)
    lambda { 
      StuffToDo.reorder_list(user)
    }.should raise_error
  end
  
  it 'should find all the Stuff To Do items' do
    user = mock_model(User)
    ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    stuff_to_dos = []
    ids.each do |id|
      stuff_to_dos << mock_model(StuffToDo, :stuff_id => id, :insert_at => true)
    end
    
    StuffToDo.should_receive(:find_all_by_user_id_and_stuff_type).with(user.id, 'Issue').and_return(stuff_to_dos)
    StuffToDo.should_receive(:find_all_by_user_id_and_stuff_type).with(user.id, 'Project').and_return([])
    StuffToDo.reorder_list(user, ids)
  end

  
  it 'should save the positions of the stuff to do items to the database' do
    user = mock_model(User)
    ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    stuff_to_dos = []
    ids.each_with_index do |id, array_position|
      stuff_to_do = mock_model(StuffToDo, :stuff_id => id, :id => id)
      stuff_to_do.should_receive(:insert_at).with(array_position + 1)
      stuff_to_dos << stuff_to_do
    end
    
    StuffToDo.should_receive(:find_all_by_user_id_and_stuff_type).with(user.id, 'Issue').and_return(stuff_to_dos)
    StuffToDo.should_receive(:find_all_by_user_id_and_stuff_type).with(user.id, 'Project').and_return([])
    StuffToDo.reorder_list(user, ids)
    
  end
  
  it 'should add new StuffToDo that are in the list but not in the database' do
    user = mock_model(User)
    ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    stuff_to_dos = []
    ids.each_with_index do |id, array_position|
      stuff_to_dos << mock_model(StuffToDo, :stuff_id => id, :insert_at => true) unless id == "820"
    end

    stuff_to_do_for_820 = StuffToDo.new
    stuff_to_do_for_820.should_receive(:stuff_id=).with(820)
    stuff_to_do_for_820.should_receive(:user_id=).with(user.id)
    stuff_to_do_for_820.should_receive(:save).and_return(true)
    position = ids.index("820") + 1
    stuff_to_do_for_820.should_receive(:insert_at).with(position)
    StuffToDo.should_receive(:new).and_return(stuff_to_do_for_820)
    
    StuffToDo.should_receive(:find_all_by_user_id_and_stuff_type).with(user.id, 'Issue').and_return(stuff_to_dos)
    StuffToDo.should_receive(:find_all_by_user_id_and_stuff_type).with(user.id, 'Project').and_return([])
    StuffToDo.reorder_list(user, ids)
  end
  
  it 'should support adding new Project StuffToDo items' do
    user = mock_model(User)
    ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    stuff_to_dos = []
    ids.each_with_index do |id, array_position|
      stuff_to_do = mock_model(StuffToDo, :stuff_id => id, :id => id)
      stuff_to_do.should_receive(:insert_at).with(array_position + 1)
      stuff_to_dos << stuff_to_do
    end

    # Project 42
    ids << "project42"
    new_project_stuff_to_do = mock_model(StuffToDo, :user_id => user.id, :insert_at => ids.size)
    new_project_stuff_to_do.should_receive(:stuff_id=).with(42)
    new_project_stuff_to_do.should_receive(:stuff_type=).with('Project')
    new_project_stuff_to_do.should_receive(:user_id=).with(user.id)
    new_project_stuff_to_do.should_receive(:save).and_return(true)
    StuffToDo.should_receive(:new).and_return(new_project_stuff_to_do)
    
    StuffToDo.should_receive(:find_all_by_user_id_and_stuff_type).with(user.id, 'Issue').and_return(stuff_to_dos)
    StuffToDo.should_receive(:find_all_by_user_id_and_stuff_type).with(user.id, 'Project').and_return([])
    StuffToDo.reorder_list(user, ids)
    
  end
  
  it 'should destroy any StuffToDos that are not in the list' do
    user = mock_model(User)
    ids = ["598", "709", "746", "1492", "1491", "820", "1094", "1095"]
    stuff_to_dos = []
    ids.each_with_index do |id, array_position|
      stuff_to_dos << mock_model(StuffToDo, :stuff_id => id, :insert_at => true)
    end

    extra_stuff_to_do = mock_model(StuffToDo, :stuff_id => 999)
    extra_stuff_to_do.should_receive(:destroy).and_return(true)
    StuffToDo.should_receive(:find_by_user_id_and_stuff_id).with(user.id, extra_stuff_to_do.stuff_id).and_return(extra_stuff_to_do)
    stuff_to_dos << extra_stuff_to_do
    
    StuffToDo.should_receive(:find_all_by_user_id_and_stuff_type).with(user.id, 'Issue').and_return(stuff_to_dos)
    StuffToDo.should_receive(:find_all_by_user_id_and_stuff_type).with(user.id, 'Project').and_return([])
    StuffToDo.reorder_list(user, ids)

  end
  
  it 'should destroy all StuffToDos if the list is empty' do
    user = mock_model(User)
    ids = nil
    stuff_to_dos = []

    extra_stuff_to_do = mock_model(StuffToDo, :stuff_id => 999)
    extra_stuff_to_do.should_receive(:destroy).and_return(true)
    StuffToDo.should_receive(:find_by_user_id_and_stuff_id).with(user.id, extra_stuff_to_do.stuff_id).and_return(extra_stuff_to_do)
    stuff_to_dos << extra_stuff_to_do
    
    StuffToDo.should_receive(:find_all_by_user_id_and_stuff_type).with(user.id, 'Issue').and_return(stuff_to_dos)
    StuffToDo.should_receive(:find_all_by_user_id_and_stuff_type).with(user.id, 'Project').and_return([])
    StuffToDo.reorder_list(user, ids)
    
  end
end

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
    @priority1 = mock_model(Enumeration)
    @priority2 = mock_model(Enumeration)
    priorities = [@priority1, @priority2]
    Enumeration.should_receive(:priorities).and_return(priorities)

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

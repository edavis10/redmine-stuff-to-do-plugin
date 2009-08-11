require File.dirname(__FILE__) + '/../spec_helper'

describe Issue, "associations" do
  it 'should have a habtm time_grid_users' do
    Issue.should have_association(:time_grid_users, :has_and_belongs_to_many)
  end
end

describe Issue, 'after_save' do
  it 'should include update_next_issues' do
    callbacks = Issue.after_save
    callbacks.should_not be_nil
    
    callbacks.should satisfy do |callbacks|
      found = false
      callbacks.each do |callback|
        found = true if callback.method == :update_next_issues
      end
      found
    end
  end
end

describe Issue, 'update_next_issues' do
  before(:each) do
    @issue = Issue.new
    @issue.stub!(:reload)
    @issue.stub!(:closed?).and_return(false)
    StuffToDo.stub!(:remove_stale_assignments)
  end
  
  it 'should reload the issue to clear the cache holding its status' do
    @issue.should_receive(:reload)
    @issue.stub!(:closed?).and_return(true)
    @issue.update_next_issues
  end
  
  it 'should call StuffToDo#remove_associations_to if the issue is closed' do
    @issue.should_receive(:closed?).and_return(true)
    StuffToDo.should_receive(:remove_associations_to).with(@issue)
    @issue.update_next_issues
  end

  it 'should not call StuffToDo#remove_associations_to if the issue is open' do
    @issue.should_receive(:closed?).and_return(false)
    StuffToDo.should_not_receive(:remove_associations_to)
    @issue.update_next_issues
  end

  it 'should return true for the callbacks' do
    StuffToDo.stub!(:remove_associations_to)

    @issue.update_next_issues.should be_true
  end
  
  it 'should call StuffToDo#remove_stale_assignments' do
    StuffToDo.should_receive(:remove_stale_assignments).with(@issue)
    @issue.update_next_issues
  end
end

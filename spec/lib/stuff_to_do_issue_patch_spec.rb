require File.dirname(__FILE__) + '/../spec_helper'

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
    NextIssue.stub!(:remove_stale_assignments)
  end
  
  it 'should reload the issue to clear the cache holding its status' do
    @issue.should_receive(:reload)
    @issue.stub!(:closed?).and_return(true)
    @issue.update_next_issues
  end
  
  it 'should call NextIssue#closing_issue if the issue is closed' do
    @issue.should_receive(:closed?).and_return(true)
    NextIssue.should_receive(:closing_issue).with(@issue)
    @issue.update_next_issues
  end

  it 'should not call NextIssue#closing_issue if the issue is open' do
    @issue.should_receive(:closed?).and_return(false)
    NextIssue.should_not_receive(:closing_issue)
    @issue.update_next_issues
  end

  it 'should return true for the callbacks' do
    NextIssue.stub!(:closing_issue)

    @issue.update_next_issues.should be_true
  end
  
  it 'should call NextIssue#remove_stale_assignments' do
    NextIssue.should_receive(:remove_stale_assignments).with(@issue)
    @issue.update_next_issues
  end
end

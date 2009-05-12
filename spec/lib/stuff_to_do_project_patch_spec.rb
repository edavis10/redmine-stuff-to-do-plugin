require File.dirname(__FILE__) + '/../spec_helper'

describe Project, 'associations' do
  it 'should have many stuff_to_dos as "stuff"' do
    Project.should have_association(:stuff_to_dos, :has_many)
  end
end

describe Project, 'after_save' do
  it 'should include update_stuff_to_do' do
    callbacks = Project.after_save
    callbacks.should_not be_nil
    
    callbacks.should satisfy do |callbacks|
      found = false
      callbacks.each do |callback|
        found = true if callback.method == :update_stuff_to_do
      end
      found
    end
  end
end

describe Project, 'update_stuff_to_do' do
  before(:each) do
    # Can't use a mock here due to a Rails/RSpec conflict
    # https://rails.lighthouseapp.com/projects/8994/tickets/404-named_scope-bashes-critical-methods
    #
    @project = Project.new
    @project.status = Project::STATUS_ACTIVE
    @project.is_public = true
  end
  
  it 'should call StuffToDo#remove_associations_to if the project is not active' do
    @project.status = Project::STATUS_ARCHIVED
    StuffToDo.should_receive(:remove_associations_to).with(@project)
    @project.update_stuff_to_do
  end

  it 'should not call StuffToDo#remove_associations_to if the project is active' do
    StuffToDo.should_not_receive(:remove_associations_to)
    @project.update_stuff_to_do
  end

  it 'should return true for the callbacks' do
    StuffToDo.stub!(:remove_associations_to)

    @project.update_stuff_to_do.should be_true
  end
end

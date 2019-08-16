require File.expand_path('../../test_helper', __FILE__)

# TESTING:
#  (create "test" entry in config/databases.ymli for test-db)
#  bundle install --with test
#  ENV=test RAILS_ENV=test bin/rake redmine:load_default_data
#  ENV=test RAILS_ENV=test bin/rake redmine:plugins:test 2>&1 |tee LOG

class StuffToDoTest < ActiveSupport::TestCase
  fixtures :users, :issues, :projects, :trackers, :projects_trackers, 
           :issue_statuses, :enumerations

  def setup
    @user = User.find(2)
    @project = Project.find(1)
  end

  def test_nothing
    @available = StuffToDo.available(@user, nil, @user);
    @assigned = StuffToDo.assigned(@user);
    assert @available.empty?
  end

  # Test create
  def test_add_and_remove
    StuffToDo.add(2, 1, "true") # user_id, issue_id, in_front
    @assigned = StuffToDo.assigned(@user);
    assert !@assigned.empty?

    StuffToDo.remove(2, 1) # user_id, issue_id
    @assigned = StuffToDo.assigned(@user);
    assert @assigned.empty?
  end

  def test_available
    @available = StuffToDo.available(@user, @project, Project.new);
    assert !@available.empty?
  end

end


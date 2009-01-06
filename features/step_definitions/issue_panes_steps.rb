# Mocha mocks

Before do
  # I hate database tests....
  User.destroy_all
  Project.destroy_all
  Enumeration.destroy_all
  IssueStatus.destroy_all
  NextIssue.destroy_all
  Issue.destroy_all
  @current_user = User.new(:mail => 'test@example.com', :firstname => 'Feature', :lastname => 'Test')
  @current_user.login = 'feature_test'
  @current_user.save!
  
  @project = Project.create!({ :identifier => 'test-project', :name => 'Test Project'})
  @low_priority = Enumeration.create!(:opt => 'IPRI', :name => 'Low')
  @new_status = IssueStatus.create!(:name => 'New', :is_closed => false)
end

Given /^there is another user named (\w+)$/ do |name|
  @other_user = User.new(:mail => "#{name.downcase}@example.com", :firstname => name, :lastname => 'Test')
  @other_user.login = name
  @other_user.save!
end

Given /^I am logged in$/ do
  User.stubs(:current).returns(@current_user)
end

Given /^I am logged in as an administrator$/ do
  @current_user.stubs(:admin?).returns(true)
  User.stubs(:current).returns(@current_user)
end

Given /^I am logged in as a user$/ do
  @current_user.stubs(:admin?).returns(false)
  User.stubs(:current).returns(@current_user)
end

Given /^I am on the stuff to do page$/ do
  visit "/stuff_to_do"
end

Given /^I am on the stuff to do page for (\w+)$/ do |user_name|
  user = User.find_by_login(user_name)
  user.should_not be_nil
  visit "/stuff_to_do", :get, :user_id => user.id
end

Given /^there are (\d+) next issues$/ do |number|
  number.to_i.times do |n|
    issue = Issue.new(:project => @project, :subject => "Issue #{number}", :description => "Description #{number}", :priority => @low_priority, :status => @new_status, :assigned_to => @current_user, :done_ratio => 50, :estimated_hours => 3)
    issue.save false # Skip all the extra associations Redmine uses
    NextIssue.create! :user => @current_user, :issue => issue
  end
end

Given /^there are (\d+) next issues for (\w+)/ do |number, user_name|
  user = User.find_by_login(user_name)
  user.should_not be_nil

  number.to_i.times do |n|
    issue = Issue.new(:project => @project, :subject => "Issue #{number}", :description => "Description #{number}", :priority => @low_priority, :status => @new_status, :assigned_to => user)
    issue.save false # Skip all the extra associations Redmine uses
    NextIssue.create! :user => user, :issue => issue
  end
end

Given /^there are (\d+) issues assigned to (\w+)$/ do |number, user_name|
  if user_name.match(/me/i)
    user = @current_user
  else
    user = User.find_by_login(user_name)
  end

  number.to_i.times do |n|
    issue = Issue.new(:project => @project, :subject => "Issue #{number}", :description => "Description #{number}", :priority => @low_priority, :status => @new_status, :assigned_to => user, :estimated_hours => 1)
    issue.save false # Skip all the extra associations Redmine uses
  end
end

Given /^there are (\d+) issues not assigned to (\w+)$/ do |number, user_name|
  number.to_i.times do |n|
    issue = Issue.new(:project => @project, :subject => "Issue #{number}", :description => "Description #{number}", :priority => @low_priority, :status => @new_status, :assigned_to => nil)
    issue.save false # Skip all the extra associations Redmine uses
  end
end

When /^I go to the stuff to do page for (\w+)$/ do |user_name|
  user = User.find_by_login(user_name)
  user.should_not be_nil
  visit "/stuff_to_do", :get, :user_id => user.id
end

When /^I submit the form "user_switch"$/ do
  submit_form("user_switch")
end


Then /^I should see a list of tasks called "(.*)"$/ do |named|
  response.should have_tag("ol##{named}")
end

Then /^I should see a row for (\d+) "(.*)" tasks$/ do |number, named|
  response.should have_tag("ol##{named}") do
    with_tag("li.issue", :minimum => number.to_i, :maximum => number.to_i)
  end
end

Then /^I should see a row for each task to do now$/ do
  response.should have_tag("li")
end

Then /^there should be a select field called "(\w+)"$/ do |element_name|
  response.should have_tag("select##{element_name}")
end

Then /^(\w+) should be in the select field$/ do |user_name|
  response.should have_tag("option", :text => /#{user_name}/)
end

Then /^(\w+) should be selected$/ do |user_name|
  response.should have_tag("option[selected=selected]", :text => /#{user_name}/)
end

Then /^"(\w+)" should be an option group in the select field "(\w+)"$/ do |option_value, field|
  response.should have_tag("select##{field}") do
    with_tag("optgroup", :label => /#{option_value}/)
  end
end

Then /^I should be the stuff to do page$/ do
  response.should be_success
  response.request.url.should match(/stuff_to_do/)
end

Then /should be redirected to the stuff to do page$/ do
  response.should be_redirect
  response.should redirect_to('/stuff_to_do')
end

Then /^I should get a 403 error$/ do
  response.code.should eql('403')
end

Then /^see the 403 error page$/ do
  response.should render_template("common/403")
end

Then /^I should see a progress graph, "([\w-]+)", at (\d+)%$/ do |css, amount|
  left = 100 - amount.to_i

  response.should have_tag("##{css}") do
    with_tag("table.progress") do
      with_tag("td.closed[style='width: #{amount}%;']") unless amount == '0'
      with_tag("td.todo[style='width: #{left}%;']")
    end
  end
end

Then /^I should see a "(\d+) hours" for "([\w-]+)"$/ do |hours, css|
  response.should have_tag("##{css}", /#{hours}/)
end


# TODO: Redmine needs so much built up, this test is unresponable (issue > project > custom fields, custom values, trackers)
# Then /^I should see the issue title in the row$/ do
#   response.should  have_tag("li", 'Issue 1 Title')
# end

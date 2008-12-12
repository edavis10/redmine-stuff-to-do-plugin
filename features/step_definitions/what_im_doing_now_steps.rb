# Mocha mocks

Given /I am logged in/ do
  @current_user = User.new(:mail => 'test@example.com', :firstname => 'Feature', :lastname => 'Test')
  @current_user.login = 'feature_test'
  @current_user.save!

  User.stubs(:current).returns(@current_user)
end

Given /I am on the stuff to do page/ do
  visit "/stuff_to_do"
end

Given /there are (\d+) next issues/ do |number|
  NextIssue.destroy_all
  number.to_i.times do |n|
    NextIssue.create! :user => @current_user
  end
end


Then /^I should see a list of tasks called "doing-now"$/ do
  response.should have_tag("ul#doing-now")
end

Then /^I should see a row for each task to do now$/ do
  response.should have_tag("li")
end

# TODO: Redmine needs so much built up, this test is unresponable (issue > project > custom fields, custom values, trackers)
# Then /^I should see the issue title in the row$/ do
#   response.should  have_tag("li", 'Issue 1 Title')
# end


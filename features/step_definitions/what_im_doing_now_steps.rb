Given /I am on the stuff to do page/ do
  visit "/stuff_to_do"
end

Then /^I should see a list of tasks called "doing-now"$/ do
  response.should have_tag("ul#doing-now")
end

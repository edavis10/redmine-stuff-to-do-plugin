Feature: Time grid
  As a user
  I want to be able to log time
  So I don't have to leave the Stuff to Do panel to log time

  Scenario: See the weekly timelog table
    Given there are 3 issues to do
    And there are 2 projects to do
    And I am logged in
    And there is "4" hours logged to an issue "today"
    And there is "10" hours logged to an issue "yesterday"
    And I am on the stuff to do page

    Then I should see "Time Grid"
    And I should see the time grid table
    And the time grid should have "4" hours for "today"
    And the time grid should have "10" hours for "yesterday"


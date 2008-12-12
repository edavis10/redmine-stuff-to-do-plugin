Feature: What I'm doing now
  In order to work on a task
  user
  wants to have a prioritized list of their tasks to do now.

  Scenario: See a prioritized list of tasks
    Given I am logged in
    And I am on the stuff to do page
    And there are 5 next issues
    Then I should see "What I'm doing now"
    And I should see a list of tasks called "doing-now"
    And I should see a row for each task to do now
    And I should see the issue title in the row


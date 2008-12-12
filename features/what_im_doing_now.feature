Feature: What I'm doing now
  In order to work on a task
  user
  wants to have a prioritized list of their tasks to do now.

  Scenario: See a prioritized list of tasks to do now
    Given there are 5 next issues
    And I am logged in
    And I am on the stuff to do page

    Then I should see "What I'm doing now"
    And I should see a list of tasks called "doing-now"
    And I should see a row for 5 to do now tasks
    And I should see the issue title in the row

  Scenario: See a prioritized list of recommended tasks
    Given there are 15 next issues
    And I am logged in
    And I am on the stuff to do page
    Then I should see "What's recommended to do next"
    And I should see a list of tasks called "recommended"
    And I should see a row for 10 recommended tasks

  Scenario: See a list of all assigned tasks
    Given there are 30 issues assigned to me
    And there are 5 next issues
    And there are 10 issues not assigned to me
    And I am logged in
    And I am on the stuff to do page
    Then I should see "What's available"
    And I should see a list of tasks called "available"
    And I should see a row for 30 available tasks
    And I should not see the next issue in the available task list

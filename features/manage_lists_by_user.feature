Feature: Manage my own lists
  As a user with issues to work on
  I want to be able to manage my own stuff to do
  So I can let my manager know the order of things I'm working on

  Scenario: See my list of tasks
    Given there are 50 issues assigned to me
    And there are 10 next issues
    And there are 10 issues not assigned to me
    And I am logged in
    And I am on the stuff to do page

    Then I should see "What's available"
    And I should see a list of tasks called "available"
    And I should see a row for 50 "available" tasks

    And I should see "What I'm doing now"
    And I should see a list of tasks called "doing-now"
    And I should see a row for 5 "doing-now" tasks

    And I should see "What's recommended to do next"
    And I should see a list of tasks called "recommended"
    And I should see a row for 5 "recommended" tasks


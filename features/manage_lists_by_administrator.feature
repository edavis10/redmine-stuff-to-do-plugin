Feature: Manage another users lists as an Administrator
  As an administrator
  I want to be able to manage another user's own stuff to do
  So I can prioritize their tasks for them

  Scenario: See list of tasks for another user
    Given there is another user named Joe
    And there are 50 issues assigned to Joe
    And there are 10 next issues for Joe
    And there are 10 issues not assigned to Joe
    And I am logged in as an administrator
    And I am on the stuff to do page for Joe

    Then I should see "What's available"
    And I should see a list of tasks called "available"
    And I should see a row for 50 "available" tasks

    And I should see "What I'm doing now"
    And I should see a list of tasks called "doing-now"
    And I should see a row for 5 "doing-now" tasks

    And I should see "What's recommended to do next"
    And I should see a list of tasks called "recommended"
    And I should see a row for 5 "recommended" tasks


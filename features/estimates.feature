Feature: Estimates
  As a user with stuff to work on
  I want to see the estimates for my stuff to do
  So I know how much work I have

  Scenario: See the a total progress below the What I'm doing now pane
    Given there are 5 issues to do
    And I am logged in
    And I am on the stuff to do page

    Then I should see "Total Progress"
    And I should see a progress graph, "doing-now-total-progress", at 50%

  Scenario: See the total estimates below the What I'm doing now pane
    Given there are 5 issues to do
    And I am logged in
    And I am on the stuff to do page

    Then I should see "Total Estimates"
    And I should see a "15 hours" for "doing-now-estimates"

  Scenario: See the a total progress below the Whats Recommended to do next pane
    Given there are 15 issues to do
    And I am logged in
    And I am on the stuff to do page

    Then I should see "Total Progress"
    And I should see a progress graph, "recommended-total-progress", at 50%

  Scenario: See the total estimates below the Whats Recommended to do next pane
    Given there are 15 issues to do
    And I am logged in
    And I am on the stuff to do page

    Then I should see "Total Estimates"
    And I should see a "30 hours" for "recommended-estimates"

  Scenario: See the a total progress below the What's Available pane
    Given there are 30 issues assigned to me
    And I am logged in
    And I am on the stuff to do page

    Then I should see "Total Progress"
    And I should see a progress graph, "available-total-progress", at 0%

  Scenario: See the total estimates below the Whats Available pane
    Given there are 30 issues assigned to me
    And I am logged in
    And I am on the stuff to do page

    Then I should see "Total Estimates"
    And I should see a "30 hours" for "available-estimates"


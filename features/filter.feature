Feature: Filtering
  As an administrator
  I want to be able to control how the What's Available list is filtered
  So I can quickly find work to assign

  Scenario: Administrators should see a drop down to change the current filter
    Given I am logged in as an administrator
    And I am on the stuff to do page

    Then I should see "Filter"
    And there should be a select field called "filter"
    And "User" should be an option group in the select field "filter"
    And "Priority" should be an option group in the select field "filter"
    And "Status" should be an option group in the select field "filter"
    And "Feature Test" should be selected


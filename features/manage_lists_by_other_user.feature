Feature: Manage another users lists as an Administrator
  As a user
  I should not be able to manage other user's lists

  Scenario: Not allowed to see another user's list
    Given there is another user named Joe
    And I am logged in as a user

    When I go to the stuff to do page for Joe

    Then I should get a 403 error
    And see the 403 error page


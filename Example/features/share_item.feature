Feature: Select item and add to print queue

  @done
  @smoke
  Scenario: Select 4x6 image and add to print queue
    Given I am on the "PrintPod" screen
    Then I should see the "Share Item" screen
    And I touch "Share Item"
    And I touch "4x6 portrait"
    And I touch Print Queue
    And I wait for some seconds
    Then I should see the "Add Print" screen
    When I touch "Add to Print Queue"
    Then I should see the "Print Queue" screen
    When I touch "Done"

  @done
  Scenario: Select 5x7 landscape image and add to print queue
    Given I am on the "PrintPod" screen
    Then I should see the "Share Item" screen
    And I touch "Share Item"
    And I touch "5x7 landscape"
    And I touch Print Queue
    And I wait for some seconds
    Then I should see the "Add Print" screen
    When I touch "Add to Print Queue"
    Then I should see the "Print Queue" screen
    When I touch "Done"

  @done
  Scenario: Select 1 page PDF and add to print queue
    Given I am on the "PrintPod" screen
    Then I should see the "Share Item" screen
    And I touch "Share Item"
    And I scroll screen to find "1 Page"
    And I touch "1 Page"
    And I touch Print Queue
    And I wait for some seconds
    Then I should see the "Add Print" screen
    When I touch "Add to Print Queue"
    Then I should see the "Print Queue" screen
    When I touch "Done"

  @done
  Scenario: Select 6 Page landscape PDF and add to print queue
    Given I am on the "PrintPod" screen
    Then I should see the "Share Item" screen
    And I touch "Share Item"
    And I scroll screen to find "6 Pages (landscape)"
    And I touch "6 Pages (landscape)"
    And I touch Print Queue
    And I wait for some seconds
    Then I should see the "Add Print" screen
    When I touch "Add to Print Queue"
    Then I should see the "Print Queue" screen
    When I touch "Done"
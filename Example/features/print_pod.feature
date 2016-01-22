Feature: Verify Print Pod home page

  @done
  Scenario: Select Print Item
    Given I am on the "PrintPod" screen
    Then I should see "Print Item"
    And I touch "Print Item"
    Then I should see the "Print Item" screen



  @done
  Scenario: Select Share Item
    Given I am on the "PrintPod" screen
    Then I should see "Share Item"
    And I touch "Share Item"
    Then I should see the "Share Item" screen

  @done
  Scenario: Select Direct Print Item
    Given I am on the "PrintPod" screen
    Then I should see "Direct Print Item"
    And I touch "Direct Print Item"
    Then I should see the "Direct Print Item" screen

  @TA12753
  Scenario: Select Show Print Queue
    Given I am on the "PrintPod" screen
    Then I should see "Show Print Queue"
    And I touch "Show Print Queue"
    Then I should see the "Print Queue" screen
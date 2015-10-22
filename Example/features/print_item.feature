Feature: Select a Print item and print

  @done
  Scenario: Select 4x6 image and print
    Given I am on the "PrintPod" screen
    Then I should see "Print Item"
    And I touch "Print Item"
    And I touch "4x6 portrait"
    Then I run print simulator
    And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I choose print button
    And I delete printer simulater generated files

  @done
  @smoke
  Scenario: Select Balloons image and print
    Given I am on the "PrintPod" screen
    Then I should see "Print Item"
    And I touch "Print Item"
    And I scroll screen to find "Balloons"
    And I touch "Balloons"
    Then I run print simulator
    And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I choose print button
    And I delete printer simulater generated files

  @done
  @smoke
  Scenario: Select 1 Page Landscape PDF and print
    Given I am on the "PrintPod" screen
    Then I should see "Print Item"
    And I touch "Print Item"
    And I scroll screen to find "1 Page (landscape)"
    And I touch "1 Page (landscape)"
    Then I run print simulator
    And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I choose print button
    And I delete printer simulater generated files

  @done
  Scenario: Select 10 Page PDF and print
    Given I am on the "PrintPod" screen
    Then I should see "Print Item"
    And I touch "Print Item"
    And I scroll screen to find "10 Pages"
    And I touch "10 Pages"
    Then I run print simulator
    And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I choose print button
    And I delete printer simulater generated files
Feature: Select a Print item and print

  @TA12753
  @ios8
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
    
    @TA12437
    @reset
     Scenario Outline: Select 3-up and 4-up and do print
    Given I am on the "PrintPod" screen
    Then I should see "Print Item"
    And I touch "Print Item"
    And I scroll screen to find "<option>"
    Then I wait for some seconds
    And I touch "<option>"
    Then I wait for some seconds
    Then I run print simulator
    And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I choose print button
    And I delete printer simulater generated files
    
    Examples:
		| option |
        | 3up   |
        | 4up   |
        
  @TA12753
  @ios8
  @reset
     Scenario Outline: Verify share item to add print queue 3up and 4up
    Given I am on the "Share Item" screen
    And I scroll screen to find "<option>"
    Then I wait for some seconds
    And I touch "<option>"
    And I touch Print Queue
    And I wait for some seconds
    Then I should see the "Add Print" screen
    And I touch "Add to Print Queue"
    Then I should see the "Print Queue" screen
    
    Examples:
		| option |
        | 3up   |
        | 4up   |
        
    @done
    @reset
     Scenario: Verify Direct Print Item
    Given I am on the "PrintPod" screen
    And I scroll screen to find "Configure"
    Then I touch Configure to set up direct print
    And I touch "4x6 portrait"
    Then I run print simulator
    And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I touch "Done"
    And I scroll screen up to find "Direct Print Item"
    And I touch "Direct Print Item"
    And I scroll screen to find "3up"
    And I touch "3up"
    Then I wait for some seconds
    And I delete printer simulater generated files
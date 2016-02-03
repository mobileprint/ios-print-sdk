Feature: Select a Print item and print from client UI

 
    @done
    @reset
    @ios8
     Scenario: Verify Print through Client UI button
    Given I am on the "PrintPod" screen
    And I scroll screen to find "BAR BUTTON ITEMS"
    And I scroll screen to find "On"
    And I touch "On"
    Then I touch "Print" through client UI
    And I touch "4x6 portrait"
    Then I run print simulator
    And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I choose print button
    And I delete printer simulater generated files

    @done
	@reset
	@ios8
     Scenario: Verify Print Queue through Client UI button
    Given I am on the "PrintPod" screen
    And I scroll screen to find "BAR BUTTON ITEMS"
    And I scroll screen to find "On"
    And I touch "On"
    And I scroll screen to find "Detect Wi-Fi"
    And I switch off "Detect Wi-Fi"
    Then I touch "Print Queue" through client UI
    And I touch "4x6 portrait"
    And I wait for some seconds
    Then I should see the "Add Print" screen
    And I touch "Add to Print Queue"
    And I wait for some seconds
    Then I should see the "Print Queue" screen
    When I touch "Done"
    Then I should see the "PrintPod" screen
    
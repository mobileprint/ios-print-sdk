Feature: Select item and add to print queue

  @reset
  @TA11948
  Scenario: Verify item added to print queue
    Given I am on the "PrintPod" screen
    Then I should see the "Share Item" screen
    And I touch "Share Item"
    And I touch "4x6 portrait"
    And I touch Print Queue
    And I wait for some seconds
    Then I should see the "Add Print" screen
    And I touch "Add to Print Queue"
    Then I should see the "Print Queue" screen
    When I touch "Done"
    Then I should see the "PrintPod" screen
    And I touch "Show Print Queue"
    Then I should see the "Print Queue" screen
    And I should see the added item 
    
    @reset
  @TA11948
  Scenario: verify print for the item from print queue
    Given I am on the "PrintPod" screen
    Then I should see the "Share Item" screen
    And I touch "Share Item"
    And I touch "4x6 portrait"
    And I touch Print Queue
    And I wait for some seconds
    Then I should see the "Add Print" screen
    And I touch "Add to Print Queue"
    Then I should see the "Print Queue" screen
    When I touch "Done"
    Then I should see the "PrintPod" screen
    And I touch "Show Print Queue"
    Then I should see the "Print Queue" screen
    Then I touch "Next"
    Then I should see the "Page Settings" screen
    Then I run print simulator 
    And I scroll screen down
    And I scroll down until "Simulated InkJet" is visible in the list
    Then I click print button
    Then I wait for some seconds
    
    @reset
  @TA11948
  Scenario: Verify Print queue buttons
    Given I am on the "PrintPod" screen
    And I touch "Share Item"
    And I touch "4x6 portrait"
    And I touch Print Queue
    And I wait for some seconds
    And I touch "Add to Print Queue"
    When I touch "Done"
    And I touch "Share Item"
    And I touch "4x6 portrait"
    And I touch Print Queue
    And I wait for some seconds
    And I touch "Add to Print Queue"
    And I wait for some seconds
    And I check "Done" button "Enabled"
    And I check "Check Box" button "Unchecked"
    And I check "Select All" button "Enabled"
    And I check "Delete" button "Disabled"
    And I check "Next" button "Disabled"
    
    @reset
  @TA11948
  Scenario: Verify print queue job selection and deselection
    Given I am on the "PrintPod" screen
    And I touch "Share Item"
    And I touch "4x6 portrait"
    And I touch Print Queue
    And I wait for some seconds
    And I touch "Add to Print Queue"
    When I touch "Done"
    And I touch "Share Item"
    And I touch "4x6 portrait"
    And I touch Print Queue
    And I wait for some seconds
    And I touch "Add to Print Queue"
    And I wait for some seconds
    And I touch "Select All" button
    And I verify "2" jobs "Selected"
    And I touch "Unselect All" button
    And I verify "2" jobs "Unselected"
        
    @reset
  @TA11948
        Scenario: Verify print queue job deletion
        Given I am on the "PrintPod" screen
    And I touch "Share Item"
    And I touch "4x6 portrait"
    And I touch Print Queue
    And I wait for some seconds
    And I touch "Add to Print Queue"
    When I touch "Done"
    And I touch "Share Item"
    And I touch "4x6 portrait"
    And I touch Print Queue
    And I wait for some seconds
    And I touch "Add to Print Queue"
    And I wait for some seconds
        And I "Select" a job
        And I check "Unselect All" button "Enabled"
        And I touch "Delete" button
        And I verify warning message displayed
        And I touch "Delete"
        And I check selected job is deleted
        
        @reset
  @TA11948
        Scenario: Verify print queue job print for multiple jobs
        Given I am on the "PrintPod" screen
    And I touch "Share Item"
    And I touch "4x6 portrait"
    And I touch Print Queue
    And I wait for some seconds
    And I touch "Add to Print Queue"
    When I touch "Done"
    And I touch "Share Item"
    And I touch "4x6 portrait"
    And I touch Print Queue
    And I wait for some seconds
    And I touch "Add to Print Queue"
    And I wait for some seconds
        And I touch "Select All" button
        Then I touch "Next"
        Then I should see the "Page Settings" screen
        Then I run print simulator 
    And I scroll screen down
    And I scroll down until "Simulated InkJet" is visible in the list
    And I wait for some seconds
    Then I touch "Print"
    
		
    
    

  
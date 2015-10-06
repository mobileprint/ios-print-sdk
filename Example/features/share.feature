Feature: Verify Share functionalities

  @reset
	@TA11948
	Scenario:Verify Share icon
		Given I am on the "PrintPod" screen
		When I select the share button
		Then I should see the "Share" screen
        
    @reset
	@TA11948
    Scenario:Verify print from share after incrementing copies
	Given I am on the "Share" screen
		When I touch "Print"
		Then I am on the "Page Settings" screen
        Then I run print simulator
        And I scroll screen down
        When I touch "Increment"
		Then The number of copies must be 2
        And I scroll down until "Simulated InkJet" is visible in the list
        Then I wait for some seconds
        Then I touch Print button labeled "Print 2 Pages"
        
    @reset
	@TA11948
    Scenario:Verify print from share with B&W mode on
	Given I am on the "Share" screen
		When I touch "Print"
		Then I am on the "Page Settings" screen
        Then I run print simulator
        And I scroll screen down
        When I touch switch
		Then switch should turn ON
        And I scroll down until "Simulated InkJet" is visible in the list
        Then I wait for some seconds
        Then I click print button
		
        
        @reset
	@TA11948
    Scenario:Verify add to print queue from share
	   Given I am on the "Share" screen
		And I touch Print Queue
        Then I should see the "Add Print" screen
        When I touch "Add to Print Queue"
        Then I should see the "Print Queue" screen
        When I touch "Done"
		Then I should see the "PrintPod" screen
Feature: Select a Print item and print

@reset
@TA12757
Scenario: Verify the carousal view of multipage PDF in Page Settings screen
    Given I am on the "PrintPod" screen
    And I touch "Print Item"
    And I select "10 Pages" multipage PDF
    Then I am on the "Page Settings" screen
    And I check carousal view is present
    Then I check page no for pages
    
 @reset
  @ios8
  @TA12757
  Scenario: Verify carousal view for print queue job print in Page Settings screen
  Given I am on the "PrintPod" screen
    And I touch "Share Item"
    And I touch "5x7 portrait"
    And I touch Print Queue
    And I wait for some seconds
    Then I should see the "Add Print" screen
	And I modify the name
    When I touch "Increment" and check number of copies is 2
    And I touch "Add 2 Pages"
    And I wait for some seconds
    When I touch "Done"
    Then I add "1" job to print queue
    And I wait for some seconds
    And I touch "Select All" button
    Then I touch "Next"
    Then I should see the "Page Settings" screen
    Then I verify print job details
    

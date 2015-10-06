Feature: Verify Share functionalities

  @reset
	@TA11948
	Scenario: Verify paper sizes for USA option
		Given I am on the "PrintPod" screen
        Then I touch "USA"
		And I touch "Print Item"
        And I scroll screen to find "Cat"
        And I touch "Cat"
		Then I am on the "Page Settings" screen
        And I scroll screen down
        When I touch "Paper Size" option
        Then I should see the following:
    

        | 4 x 5  |
        | 4 x 6       |
        | 5 x 7       |
        | 8.5 x 11    |
        
        @reset
	@TA11948
	Scenario: Verify paper sizes for International option
		Given I am on the "PrintPod" screen
        Then I touch "International"
		And I touch "Print Item"
        And I scroll screen to find "Cat"
        And I touch "Cat"
		Then I am on the "Page Settings" screen
        And I scroll screen down
        When I touch "Paper Size" option
        Then I should see the following:
    

        | A4  |
        | A5       |
        | A6       |
        | 10x15cm  |
        | 13x18cm  |
        | 10x13cm  |
        
         @reset
	@TA11948
	Scenario: Verify paper sizes for All option
		Given I am on the "PrintPod" screen
        Then I touch "All"
		And I touch "Print Item"
        And I scroll screen to find "Cat"
        And I touch "Cat"
		Then I am on the "Page Settings" screen
        And I scroll screen down
        When I touch "Paper Size" option
        Then I should see the following:
    
        | 4 x 5    |
        | 4 x 6    |
        | 5 x 7    |
        | 8.5 x 11 |
        | A4       |
        | A5       |
        | A6       |
        | 10x15cm  |
        | 13x18cm  |
        | 10x13cm  |
        | 2 x 6    |
        | 1.5 x 8  |
        
        @reset
	@TA11948
	Scenario Outline: Verify photo print for paper sizes for International option
		Given I am on the "PrintPod" screen
        Then I touch "International"
		And I touch "Print Item"
        And I scroll screen to find "Cat"
        And I touch "Cat"
		Then I am on the "Page Settings" screen
        And I scroll screen down
        Then I run print simulator
        And I touch "Paper Size" option
		And I should see the paper size options
		Then I selected the paper size "<size_option>"
        Then I wait for some seconds
		And I scroll down until "Simulated InkJet" is visible in the list
        And I wait for some seconds
        Then I touch "Print"
    
        Examples:
		| size_option |
        | A4  |
        | A5       |
        | A6       |
        | 10x15cm  |
        | 13x18cm  |
        | 10x13cm  |
        
          @reset
	@TA11948
	Scenario Outline: Verify pdf print for paper sizes for International option
		Given I am on the "PrintPod" screen
        Then I touch "International"
		And I touch "Print Item"
        And I scroll screen to find "1 Page"
        And I touch "1 Page"
		Then I am on the "Page Settings" screen
        And I scroll screen down
        Then I run print simulator
        And I touch "Paper Size" option
		And I should see the paper size options
		Then I selected the paper size "<size_option>"
        Then I wait for some seconds
		And I scroll down until "Simulated InkJet" is visible in the list
        And I wait for some seconds
        Then I touch "Print"
    
        Examples:
		| size_option |
        | A4  |
        | A5       |
        | A6       |
        | 10x15cm  |
        | 13x18cm  |
        | 10x13cm  |
   
   
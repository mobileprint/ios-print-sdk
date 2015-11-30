Feature: Select a Print item and print for different border types

 
    @TA12437
    @reset
     Scenario Outline: Verify force border layout for all paper sizes
    Given I am on the "PrintPod" screen
    And I scroll screen to find "LAYOUT"
    And I select "<layout_type>" layout type
    Then I touch "<layout_option>"
    And I select "<border_type>" as border type
    And I scroll screen up to find "Print Item"
    And I touch "Print Item"
    And I touch "4x6 portrait"
    Then I run print simulator
    Then I should see the "Page Settings" screen
     And I scroll screen "down"
     And I should see the paper size options
    Then I selected the paper size "<size_option>"
    And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I choose print button
    Then I wait for some seconds
    And I delete printer simulater generated files
    
    Examples:
		| layout_type |layout_option|border_type|size_option|
        | Fit         |Best         |Top        |4 x 6      |
        | Fit         |Portrait     |Middle     |5 x 7      |
        | Fit         |Landscape    |Bottom     |8.5 x 11   |
        | Fit         |Best         |Left       |4 x 6      |
        | Fit         |Portrait     |Center     |5 x 7      |
        | Fit         |Landscape    |Right      |8.5 x 11   |
        
        | Fill        |Best         |no_border  |4 x 6      |
        | Fill        |Portrait     |no_border  |5 x 7      |
        | Fill        |Landscape    |no_border  |8.5 x 11   |
        
        | Stretch     |Best         |no_border  |4 x 6      |
        | Stretch     |Portrait     |no_border  |5 x 7      |
        | Stretch     |Landscape    |no_border  |8.5 x 11   |
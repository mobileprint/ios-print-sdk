Feature: Select a Print item and print

  @test1
  Scenario: Combination of selecting Print and Cancel options on Page setting screen
    Given I am on the "PrintPod" screen
    Then I should see "Print Item"
    And I touch "Print Item"
    And I touch "4x6 portrait"
    Then I run print simulator
    And I scroll down until "Simulated InkJet" is visible in the list
    Then I cancel print
    Then I wait for some seconds
    Then I should see the "Print Pod" screen
    And I touch "Print Item"
    And I scroll screen to find "Balloons"
    And I touch "Balloons"
    Then I run print simulator
    And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I choose print button
    Then I wait for some seconds
    Then I should see the "Print Pod" screen
    And I touch "Print Item"
    And I scroll screen to find "1 Page (landscape)"
    And I touch "1 Page (landscape)"
    Then I run print simulator
    And I scroll down until "Simulated InkJet" is visible in the list
    Then I cancel print
    Then I wait for some seconds
    Then I should see the "Print Pod" screen
    And I touch "Print Item"
    And I scroll screen to find "10 Pages"
    And I touch "10 Pages"
    Then I run print simulator
    And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I choose print button
    And I delete printer simulater generated files
    Then I wait for some seconds
    Then I should see the "Print Pod" screen
    And I touch "Print Item"
    And I scroll screen to find "5x7 landscape"
    And I touch "5x7 landscape"
    Then I run print simulator
    And I scroll down until "Simulated Laser" is visible in the list
    Then I cancel print
    Then I wait for some seconds
    Then I should see the "Print Pod" screen
    And I touch "Print Item"
    And I scroll screen to find "4x6 portrait"
    And I touch "4x6 portrait"
    Then I run print simulator
    And I scroll down until "Simulated InkJet" is visible in the list
    Then I wait for some seconds
    Then I choose print button

  @test2
  Scenario: Print multiple times
    Given I am on the "PrintPod" screen
    And I touch "Print Item" select "Balloons" multipletimes on "Simulated InkJet" printer
    And I touch "Print Item" select "10 Pages" multipletimes on "Simulated Laser" printer
    And I touch "Print Item" select "5x7 landscape" multipletimes on "Simulated InkJet" printer
Feature: As a user I want to verify the print metrics for HP, Partners and none

@TA12437
@reset
@ios8_metrics
Scenario Outline: Verify print metrics
  Given I am on the "PrintPod" screen
  And I scroll screen to find "METRICS"
  Then I touch "<metrics_option>"
  And I scroll screen up to find "Print Item"
  And I touch "Print Item"
  And I touch "4x6 portrait"
  Then I am on the "Page Settings" screen
  Then I run print simulator
  And I scroll screen "down"
  When I touch "Increment" and check number of copies is 2
  And I touch "Paper Size" option
  And I should see the paper size options
  And I scroll screen "up"
  Then I selected the paper size "<size_option>"
  And I should see the paper type options
  Then I selected the paper type "<type_option>"
  Then I wait for some seconds
  And I scroll down until "Simulated Laser" is visible in the list
  Then I wait for some seconds
  And I get the printer_name
  Then I touch Print button labeled "Print 2 Pages"
  Then I wait for some seconds
  Then Fetch metrics details
  And I check the number of copies is "2"
  And I check the manufacturer is "Apple"
  And I check the os_type is "iOS"
  And I check black_and_white_filter value is "0"
  And I check the printer_location
  And I check the printer_model is "Simulated Laser"
  And I check the printer_name
  And I check the image_url
   And I check the user_id is "1234567890"
  And I check the paper size is "<size_option>"
  And I check the paper type is "<type_option>"
  And I check the product name is "MobilePrintSDK-cal"
  And I check the device brand is "Apple"
  And I check the off ramp is "PrintFromClientUI"
  And I check the device type is "x86_64"
  And I check the os version
  
  Examples:
  |size_option  |type_option    |metrics_option|
  | 4 x 5       | Photo Paper   |HP            |
  | 4 x 6       | Photo Paper   |Partner       |
  | 5 x 7       | Photo Paper   |HP            |
  | 8.5 x 11    | Plain Paper   |Partner       |
  | 8.5 x 11    | Photo Paper   |HP            |
  
  
@TA12437
@reset
@ios8_metrics
Scenario Outline: Verify print metrics for None
  Given I am on the "PrintPod" screen
  And I scroll screen to find "METRICS"
  Then I touch "<metrics_option>"
  And I scroll screen up to find "Print Item"
  And I touch "Print Item"
  And I touch "4x6 portrait"
  Then I am on the "Page Settings" screen
  Then I run print simulator
  And I scroll screen "down"
  When I touch "Increment" and check number of copies is 2
  And I touch "Paper Size" option
  And I should see the paper size options
  And I scroll screen "up"
  Then I selected the paper size "<size_option>"
  And I should see the paper type options
  Then I selected the paper type "<type_option>"
  Then I wait for some seconds
  And I scroll down until "Simulated Laser" is visible in the list
  Then I wait for some seconds
  Then Fetch metrics details
  Then I touch Print button labeled "Print 2 Pages"
  Then I wait for some seconds
  And I verify metrics not generated for current print
  
   Examples:
  |size_option  |type_option    |metrics_option|
  | 4 x 5       | Photo Paper   |None          |
  | 4 x 6       | Photo Paper   |None          |
  | 5 x 7       | Photo Paper   |None          |
  | 8.5 x 11    | Plain Paper   |None          |
  | 8.5 x 11    | Photo Paper   |None          |
  
   @done
   @TA12437
    @reset
    @ios8_metrics
     Scenario Outline: Verify print metrics for Direct Print Item
    Given I am on the "PrintPod" screen
    And I scroll screen to find "Configure"
    Then I touch Configure to set up direct print
    And I touch "4x6 portrait"
    Then I wait for some seconds
    Then I run print simulator
    And I scroll screen "down"
    And I touch "Paper Size" option
  And I should see the paper size options
  And I scroll screen "up"
  Then I selected the paper size "<size_option>"
  And I should see the paper type options
  Then I selected the paper type "<type_option>"
  Then I wait for some seconds
  And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I touch "Done"
    And I scroll screen up to find "Direct Print Item"
    And I touch "Direct Print Item"
    And I scroll screen to find "3up"
    And I touch "3up"
    Then I wait for some seconds
    Then Fetch metrics details
    And I check the manufacturer is "Apple"
  And I check the os_type is "iOS"
  And I check black_and_white_filter value is "0"
  And I check the printer_location
  And I check the printer_model is "Simulated Laser"
  And I check the printer_name
  And I check the image_url
   And I check the user_id is "1234567890"
  And I check the paper size is "<size_option>"
  And I check the paper type is "<type_option>"
  And I check the product name is "MobilePrintSDK-cal"
  And I check the device brand is "Apple"
  And I check the off ramp is "PrintWithNoUI"
  And I check the device type is "x86_64"
  And I check the os version
  
  Examples:
  |size_option  |type_option    |
  | 4 x 5       | Photo Paper   |
  | 4 x 6       | Photo Paper   |
  | 5 x 7       | Photo Paper   |
  | 8.5 x 11    | Plain Paper   |
  | 8.5 x 11    | Photo Paper   |
  
  
  @TA12437
@reset
@ios7_metrics
Scenario Outline: Verify print metrics
  Given I am on the "PrintPod" screen
  And I scroll screen to find "METRICS"
  Then I touch "<metrics_option>"
  And I scroll screen up to find "Print Item"
  And I touch "Print Item"
  And I touch "4x6 portrait"  
  Then I am on the "Page Settings" screen
  Then I run print simulator
  And I scroll screen "down"
  And I touch "Paper Size" option
  And I should see the paper size options
  And I scroll screen "up"
  Then I selected the paper size "<size_option>"
  And I should see the paper type options
  Then I selected the paper type "<type_option>"
  Then I wait for some seconds
  And I touch "Print"
  Then I wait for some seconds
  And I scroll down until "Simulated Laser" is visible in the list
  Then I choose print button
  Then I wait for some seconds
  Then Fetch metrics details
  And I check the number of copies is "1"
  And I check the manufacturer is "Apple"
  And I check the os_type is "iOS"
  And I check black_and_white_filter value is "1"
  And I check the printer_location
  And I check the printer_model is "Simulated Laser"
  And I check the printer_name
  And I check the image_url
   And I check the user_id is "1234567890"
  And I check the paper size is "<size_option>"
  And I check the paper type is "<type_option>"
  And I check the product name is "MobilePrintSDK-cal"
  And I check the device brand is "Apple"
  And I check the off ramp is "PrintFromClientUI"
  And I check the device type is "x86_64"
  And I check the os version
  
  Examples:
  |size_option  |type_option    |metrics_option|
  | 4 x 5       | Photo Paper   |HP            |
  | 4 x 6       | Photo Paper   |Partner       |
  | 5 x 7       | Photo Paper   |HP            |
  | 8.5 x 11    | Plain Paper   |Partner       |
  | 8.5 x 11    | Photo Paper   |HP            |
  
  
@TA12437
@reset
@ios7_metrics
Scenario Outline: Verify print metrics for None
  Given I am on the "PrintPod" screen
  And I scroll screen to find "METRICS"
  Then I touch "<metrics_option>"
  And I scroll screen up to find "Print Item"
  And I touch "Print Item"
  And I touch "4x6 portrait"
  Then I am on the "Page Settings" screen
  Then I run print simulator
  And I scroll screen "down"
  And I touch "Paper Size" option
  And I should see the paper size options
  And I scroll screen "up"
  Then I selected the paper size "<size_option>"
  And I should see the paper type options
  Then I selected the paper type "<type_option>"
  Then I wait for some seconds
  And I touch "Print"
  Then I wait for some seconds
  And I scroll down until "Simulated Laser" is visible in the list
  Then Fetch metrics details
  Then I choose print button
  Then I wait for some seconds
  And I verify metrics not generated for current print
  
   Examples:
  |size_option  |type_option    |metrics_option|
  | 4 x 5       | Photo Paper   |None          |
  | 4 x 6       | Photo Paper   |None          |
  | 5 x 7       | Photo Paper   |None          |
  | 8.5 x 11    | Plain Paper   |None          |
  | 8.5 x 11    | Photo Paper   |None          |
  
   
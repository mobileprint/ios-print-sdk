Feature: As a user I want to verify the print metrics for HP, Partner and none

  @reset
  @done
  Scenario Outline: Verify event metrics for HP and Partner
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I get the version
    And I scroll screen to find "Use unique ID per app"
    Then I get the device id
    Then I enter custom library version
    And I scroll screen to find "METRICS"
    Then I touch "<metrics_option>"
    And I scroll screen up to find "Print Item"
    And I touch "Print Item"
    And I touch "4x6 portrait"
    Then I should see the "Page Settings" screen
    Then I wait for some seconds
    Then I Fetch event metrics details
    And I check the device id
    And I check the device type is "x86_64"
    And I check the os_type is "iOS"
    And I check the version
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "com.hp.dev.MobilePrintSDK-cal"
    And I check the library version        
    And I check the application type is "<metrics_option>"
    And I check the print session id is "1"
    And I check the event count is "1"
    And I check the event type id is "1"
    And I check the os version
        
    Examples:
    | metrics_option |
    | HP             |
    | Partner        |


@reset
@done
  Scenario Outline: Verify event metrics for print from share item
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I get the version
    And I scroll screen to find "Use unique ID per app"
    Then I get the device id
    Then I enter custom library version
    And I scroll screen to find "METRICS"
    Then I touch "<metrics_option>"     
    And I scroll screen up to find "Share Item"
    And I touch "Share Item"
    And I touch "5x7 portrait"
    Then I wait for some seconds
    When I touch "Print"
    Then I Fetch event metrics details
    And I check the device id
    And I check the device type is "x86_64"
    And I check the os_type is "iOS"
    And I check the version
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "com.hp.dev.MobilePrintSDK-cal"
    And I check the library version        
    And I check the application type is "<metrics_option>"
    And I check the print session id is "1"
    And I check the event count is "1"
    And I check the event type id is "1"
    And I check the os version
    Then I touch "Cancel"
    Then I navigate to page settings screen
    Then I Fetch event metrics details
    And I check the print session id is "2"
    And I check the event count is "2"
    And I check the event type id is "1"    
    Then I should see the "Page Settings" screen
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
    And I get the printer_name
    Then I click print button
    Then I wait for some seconds
    Then I Fetch event metrics details
    And I check the device id
    And I check the device type is "x86_64"
    And I check the os_type is "iOS"
    And I check the version
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "com.hp.dev.MobilePrintSDK-cal"
    And I check the library version        
    And I check the application type is "<metrics_option>"
    And I check the print session id is "2"
    And I check the event count is "1"
    And I check the event type id is "5"
    And I check the os version
        
Examples:
      | size_option | type_option | metrics_option |
      | 4 x 5       | Photo Paper | HP             |
      | 5 x 7       | Photo Paper | Partner       |
     
  
   
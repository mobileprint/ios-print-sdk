Feature: As a user I want to verify the print metrics for HP, Partners and none

  @TA12437
  @reset
  @ios8_metrics
  Scenario Outline: Verify print metrics for HP
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
    And I scroll screen to find "METRICS"
    Then I touch "<metrics_option>"
    And I scroll screen up to find "Print Item"
    And I touch "Print Item"
    And I touch "4x6 portrait"
    Then I should see the "Page Settings" screen
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
    And I check the photo_source is "facebook"
    And I check the library version
    And I check the user_id is "1234567890"
    And I check the paper size is "<size_option>"
    And I check the paper type is "<type_option>"
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "org.cocoapods.demo.MobilePrintSDK-cal"
    And I check the application type is "HP"
    And I check the route taken is "print-metrics-test.twosmiles.com"
    And I check the device brand is "Apple"
    And I check the off ramp is "PrintFromClientUI"
    And I check the device type is "x86_64"
    And I check the os version

    Examples:
      | size_option | type_option | metrics_option |
      | 4 x 5       | Photo Paper | HP             |
      | 8.5 x 11    | Plain Paper | HP             |

  @TA12437
  @reset
  @ios8_metrics
  Scenario Outline: Verify print metrics for Partner
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
    And I scroll screen to find "METRICS"
    Then I touch "<metrics_option>"
    And I scroll screen up to find "Print Item"
    And I touch "Print Item"
    And I touch "4x6 portrait"
    Then I should see the "Page Settings" screen
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
    And I check the manufacturer is "Not Collected"
    And I check the os_type is "iOS"
    And I check black_and_white_filter value is "0"
    #And I check the printer_location
    And I check the printer_model is "Simulated Laser"
    #And I check the printer_name
    And I check the image_url
    #And I check the photo_source is "facebook"
    And I check the library version
    #And I check the user_id is "1234567890"
    And I check the paper size is "<size_option>"
    And I check the paper type is "<type_option>"
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "org.cocoapods.demo.MobilePrintSDK-cal"
    And I check the application type is "Partner"
    And I check the route taken is "print-metrics-test.twosmiles.com"
    And I check the device brand is "Not Collected"
    And I check the off ramp is "PrintFromClientUI"
    And I check the device type is "x86_64"
    And I check the os version
      
    Examples:
      | size_option | type_option | metrics_option |
      | 4 x 6       | Photo Paper | Partner        |
      | 8.5 x 11    | Plain Paper | Partner        |


  @TA12437
  @reset
  @ios8_metrics
  Scenario Outline: Verify print metrics for None
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
    And I scroll screen to find "METRICS"
    Then I touch "<metrics_option>"
    And I scroll screen up to find "Print Item"
    And I touch "Print Item"
    And I touch "4x6 portrait"
    Then I should see the "Page Settings" screen
    Then I run print simulator
    And I scroll screen "down"
    #When I touch "Increment" and check number of copies is 2
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
    Then I touch Print button labeled "Print"
    Then I wait for some seconds
    And I verify metrics not generated for current print

    Examples:
      | size_option | type_option | metrics_option |
      | 5 x 7       | Photo Paper | None           |
      | 8.5 x 11    | Plain Paper | None           |
      | 8.5 x 11    | Photo Paper | None           |

  @done
  @TA12437
  @reset
  @ios8_metrics
  Scenario Outline: Verify Direct Print Metrics for Patner
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
    And I scroll screen to find "METRICS"
    Then I touch "<metrics_option>"
    And I scroll screen to find "Configure"
    Then I touch Configure to set up direct print
    Then I wait for some seconds
    And I touch "4x6 portrait"
    And I scroll screen "down"
    And I touch "Paper Size" option
    And I should see the paper size options
    And I scroll screen "up"
    Then I selected the paper size "<size_option>"
    And I should see the paper type options
    Then I selected the paper type "<type_option>"
    Then I run print simulator
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
    And I check the number of copies is "1"
    And I check the manufacturer is "Not Collected"
    And I check the os_type is "iOS"
    And I check black_and_white_filter value is "0"
    #And I check the printer_location
    #And I check the printer_model is "Simulated Laser" -- Log Defect
    #And I check the printer_name
    And I check the image_url
    #And I check the photo_source is "facebook"
    And I check the library version
    #And I check the user_id is "1234567890"
    And I check the paper size is "<size_option>"
    And I check the paper type is "<type_option>"
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "org.cocoapods.demo.MobilePrintSDK-cal"
    And I check the application type is "<metrics_option>"
    And I check the route taken is "print-metrics-test.twosmiles.com"
    And I check the device brand is "Not Collected"
    And I check the off ramp is "PrintWithNoUI"
    And I check the device type is "x86_64"
    And I check the os version

    Examples:
      | size_option | type_option | metrics_option |
      | 8.5 x 11    | Plain Paper | Partner        |
      | 8.5 x 11    | Photo Paper | Partner        |
      | 5 x 7       | Photo Paper | Partner        |


  @done
  @TA12437
  @reset
  @ios8_metrics
  Scenario Outline: Verify Direct Print Metrics for HP
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
    And I scroll screen to find "Configure"
    Then I touch Configure to set up direct print
    Then I wait for some seconds
    And I touch "4x6 portrait"
    And I scroll screen "down"
    And I touch "Paper Size" option
    And I should see the paper size options
    And I scroll screen "up"
    Then I selected the paper size "<size_option>"
    And I should see the paper type options
    Then I selected the paper type "<type_option>"
    Then I run print simulator
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
    And I check the number of copies is "1"
    And I check the manufacturer is "Apple"
    And I check the os_type is "iOS"
    And I check black_and_white_filter value is "0"
    And I check the printer_location  
    And I check the printer_model is "Simulated Laser" 
    And I check the printer_name
    And I check the image_url
    And I check the photo_source is "facebook"
    And I check the library version
    And I check the user_id is "1234567890"
    And I check the paper size is "<size_option>"
    And I check the paper type is "<type_option>"
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "org.cocoapods.demo.MobilePrintSDK-cal"
    And I check the application type is "HP"
    And I check the route taken is "print-metrics-test.twosmiles.com"
    And I check the device brand is "Apple"
    And I check the off ramp is "PrintWithNoUI"
    And I check the device type is "x86_64"
    And I check the os version

    Examples:
      | size_option | type_option |
      | 4 x 5       | Photo Paper |
      | 8.5 x 11    | Plain Paper |

      
 @TA12603
  @reset
  @ios8_metrics
  Scenario Outline: Verify print metrics for print from share item
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
    And I scroll screen to find "METRICS"
    Then I touch "<metrics_option>"     
    And I scroll screen up to find "Share Item"
    And I touch "Share Item"
    And I touch "5x7 portrait"
    Then I wait for some seconds
    When I touch "Print"
    Then I should see the "Page Settings" screen
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
    And I check the photo_source is "facebook"
    And I check the library version
    And I check the user_id is "1234567890"
    And I check the paper size is "<size_option>"
    And I check the paper type is "<type_option>"
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "org.cocoapods.demo.MobilePrintSDK-cal"
    And I check the application type is "HP"
    And I check the route taken is "print-metrics-test.twosmiles.com"
    And I check the device brand is "Apple"
    And I check the off ramp is "PrintFromShare"
    And I check the device type is "x86_64"
    And I check the os version
    
Examples:
      | size_option | type_option | metrics_option |
      | 4 x 5       | Photo Paper | HP             |
      | 5 x 7       | Photo Paper | HP             |
      | 8.5 x 11    | Photo Paper | HP             |

@TA12603
  @reset
  @ios8_metrics
    Scenario: Verify print metrics for share item save image
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
    And I scroll screen to find "METRICS"
    Then I touch "HP"     
    And I scroll screen up to find "Share Item"
    And I touch "Share Item"
    And I scroll screen to find "Flowers"
    And I touch "Flowers"
    Then I wait for some seconds
    When I touch "Save Image"
    Then I wait for some seconds
    Then Fetch metrics details
    And I check the manufacturer is "Apple"
    And I check the os_type is "iOS"
    And I check the image_url
    And I check the photo_source is "facebook"
    And I check the library version
    And I check the user_id is "1234567890"
    And I check the printer_model is "No Print"
    And I check the paper size is "No Print"
    And I check the paper type is "No Print"
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "org.cocoapods.demo.MobilePrintSDK-cal"
    And I check the application type is "HP"
    And I check the route taken is "print-metrics-test.twosmiles.com"
    And I check the device brand is "Apple"
    And I check the off ramp is "com.apple.UIKit.activity.SaveToCameraRoll"
    And I check the device type is "x86_64"
    And I check the os version
 


@TA12603
  @reset
  @ios8_metrics
   Scenario: Verify print metrics for add to queue from share
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
    And I scroll screen up to find "Share Item"
    Then I wait for some seconds
    Then I add "1" job to print queue
    Then I wait for some seconds
    Then Fetch metrics details
    And I check the manufacturer is "Apple"
    And I check the os_type is "iOS"
    And I check the image_url
    And I check the photo_source is "facebook"
    And I check the library version
    And I check the user_id is "1234567890"
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "org.cocoapods.demo.MobilePrintSDK-cal"
    And I check the application type is "HP"
    And I check the route taken is "print-metrics-test.twosmiles.com"
    And I check the device brand is "Apple"
    And I check the device type is "x86_64"
    And I check the os version
    And I check the off ramp is "AddToQueueFromShare"
    
@TA12603
  @reset
  @ios8_metrics
   Scenario: Verify print metrics for delete from queue
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
    And I scroll screen up to find "Share Item"
    Then I wait for some seconds
    Then I add "1" job to print queue
    And I touch "Delete" button
    And I verify warning message displayed
    And I touch "Delete"
    Then I wait for some seconds
    Then Fetch metrics details
    And I check the manufacturer is "Apple"
    And I check the os_type is "iOS"
    And I check the image_url
    And I check the photo_source is "facebook"
    And I check the library version
    And I check the user_id is "1234567890"
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "org.cocoapods.demo.MobilePrintSDK-cal"
    And I check the application type is "HP"
    And I check the route taken is "print-metrics-test.twosmiles.com"
    And I check the device brand is "Apple"
    And I check the device type is "x86_64"
    And I check the os version
    And I check the off ramp is "DeleteFromQueue"
    
    
 @TA12603
  @reset
  @ios8_metrics
   Scenario Outline: Verify print metrics for printing from print queue
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
    And I scroll screen up to find "Share Item"
    Then I wait for some seconds
    Then I add "<no_of_jobs>" job to print queue
    Then I load "<no_of_jobs>" job to page settings 
    Then I wait for some seconds
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
    Then I touch "<print_option>"
    Then I wait for some seconds
    Then Fetch metrics details
    And I check the number of copies is "1"
    And I check the manufacturer is "Apple"
    And I check the os_type is "iOS"
    And I check black_and_white_filter value is "0"
    And I check the printer_location
    And I check the printer_model is "Simulated Laser"
    And I check the printer_name
    And I check the image_url
    And I check the photo_source is "facebook"
    And I check the library version
    And I check the user_id is "1234567890"
    And I check the paper size is "<size_option>"
    And I check the paper type is "<type_option>"
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "org.cocoapods.demo.MobilePrintSDK-cal"
    And I check the application type is "HP"
    And I check the route taken is "print-metrics-test.twosmiles.com"
    And I check the device brand is "Apple"
    And I check the off ramp is "<off_ramp>"
    And I check the device type is "x86_64"
    And I check the os version

Examples:
      | no_of_jobs|off_ramp              |print_option  | size_option | type_option |
      |     1     |PrintSingleFromQueue  |Print         | 4 x 5       | Photo Paper |
      |     2     |PrintMultipleFromQueue|Print All     | 8.5 x 11    | Plain Paper |
     

    
 @TA12603
  @reset
  @ios8_metrics
   Scenario: Verify print metrics for jobs added from client UI
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
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
    Then I wait for some seconds
    Then Fetch metrics details
    And I check the manufacturer is "Apple"
    And I check the os_type is "iOS"
    And I check the image_url
    And I check the photo_source is "facebook"
    And I check the library version
    And I check the user_id is "1234567890"
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "org.cocoapods.demo.MobilePrintSDK-cal"
    And I check the application type is "HP"
    And I check the route taken is "print-metrics-test.twosmiles.com"
    And I check the device brand is "Apple"
    And I check the device type is "x86_64"
    And I check the os version
    And I check the off ramp is "AddToQueueFromClientUI"
    
       
 @TA12603
  @reset
  @ios8_metrics
  
   Scenario Outline: Verify print metrics for printing from print queue with incremented no of copies
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
    And I scroll screen up to find "Share Item"
    Then I touch "Share Item"
	And I touch "4x6 portrait"
	Then I touch Print Queue
	And I wait for some seconds
    Then I should see the "Add Print" screen
	And I modify the name
    When I touch "Increment" and check number of copies is 2
	Then I touch "Add 2 Pages"
	And I wait for some seconds
    Then I touch "Next"
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
    Then I touch "Print"
    Then I wait for some seconds
    Then Fetch metrics details
    And I check the number of copies is "1"
    And I check the manufacturer is "Apple"
    And I check the os_type is "iOS"
    And I check black_and_white_filter value is "0"
    And I check the printer_location
    And I check the printer_model is "Simulated Laser"
    And I check the printer_name
    And I check the image_url
    And I check the photo_source is "facebook"
    And I check the library version
    And I check the user_id is "1234567890"
    And I check the paper size is "<size_option>"
    And I check the paper type is "<type_option>"
    And I check the product name is "MobilePrintSDK-cal"
    And I check the product id is "org.cocoapods.demo.MobilePrintSDK-cal"
    And I check the application type is "HP"
    And I check the route taken is "print-metrics-test.twosmiles.com"
    And I check the device brand is "Apple"
    And I check the off ramp is "PrintSingleFromQueue"
    And I check the device type is "x86_64"
    And I check the os version

Examples:
         | size_option | type_option |
         | 4 x 5       | Photo Paper |
         | 8.5 x 11    | Plain Paper |
     


  @TA12437
  @reset
  @ios7_metrics
  Scenario Outline: Verify print metrics for HP
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
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
      | size_option | type_option | metrics_option |
      | 4 x 5       | Photo Paper | HP             |
      | 5 x 7       | Photo Paper | HP             |
      | 8.5 x 11    | Photo Paper | HP             |

  @TA12437
  @reset
  @ios7_metrics
  Scenario Outline: Verify print metrics for Partner
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
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
    And I check the manufacturer is "Not Collected"
    And I check the os_type is "iOS"
    And I check black_and_white_filter value is "1"
   # And I check the printer_location
    And I check the printer_model is "Simulated Laser"
    #And I check the printer_name
    #And I check the image_url
   # And I check the user_id is "1234567890"
    And I check the paper size is "<size_option>"
    And I check the paper type is "<type_option>"
    And I check the product name is "MobilePrintSDK-cal"
    And I check the device brand is "Not Collected"
    And I check the off ramp is "PrintFromClientUI"
    And I check the device type is "x86_64"
    And I check the os version

    Examples:
      | size_option | type_option | metrics_option |
      | 4 x 6       | Photo Paper | Partner        |
      | 8.5 x 11    | Plain Paper | Partner        |


  @TA12437
  @reset
  @ios7_metrics
  Scenario Outline: Verify print metrics for None
    Given I am on the "PrintPod" screen
    Then I wait for some seconds
    And I scroll screen to find "Use unique ID per app"
    Then I enter custom library version
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
      | size_option | type_option | metrics_option |
      | 4 x 5       | Photo Paper | None           |
      | 4 x 6       | Photo Paper | None           |
      | 5 x 7       | Photo Paper | None           |
      | 8.5 x 11    | Plain Paper | None           |
      | 8.5 x 11    | Photo Paper | None           |
  
   
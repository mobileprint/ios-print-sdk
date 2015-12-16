Then(/^I touch Configure to set up direct print$/) do
     touch @current_page.configure_direct_print
end

Then(/^I touch "(.*?)" through client UI$/) do |option|
  if option =="Print"
      touch @current_page.print_client_ui
else if option =="Print Queue"
      touch @current_page.print_queue_client_ui
end
end
end
Given(/^I switch off "(.*?)"$/) do |option|
 if option == "Detect Wi-Fi"
     sleep(3.0)
     #touch query("view:'UISwitch' {accessibilityLabel ENDSWITH 'Detect Wi-Fi'}")
     touch query("UITableViewCellContentView label marked:'Detect Wi-Fi' sibling UISwitch")
     end
end

Then(/^I select "(.*?)" layout type$/) do |layout_type|
  macro %Q|I touch "#{layout_type}"|
end

Then(/^I select "(.*?)" as border type$/) do |border_type|
    if border_type != "no_border"
        puts "border!!"
        macro %Q|I touch "#{border_type}"|
    end
end


Then(/^I add "(.*?)" more jobs$/) do |arg1|

    macro %Q|I touch "Share Item"|
    macro %Q|I touch "4x6 portrait"|
    macro %Q|I touch Print Queue|
    macro %Q|I wait for some seconds|
    macro %Q|I should see the "Add Print" screen|
    macro %Q|I modify the name|
   macro %Q|I touch "Add to Print Queue"|
    macro %Q|I wait for some seconds|
    if arg1 == "2"
        puts "2 jobs"
        macro %Q|I touch "Done"|
        macro %Q|I add "1" more jobs|
    end
end



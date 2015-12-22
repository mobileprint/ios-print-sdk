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



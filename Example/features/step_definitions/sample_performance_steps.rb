And /^I touch "(.*?)" select "(.*?)" multipletimes on "(.*?)" printer/ do |printitem,label, printername|
  i = 0
  while i < 2
  macro %Q|I touch "#{printitem}"|
  macro %Q|I wait for some seconds|
  macro %Q|I scroll screen to find "#{label}"|
  macro %Q|I touch "#{label}"|
  macro %Q|I run print simulator|
  macro %Q|I scroll down until "#{printername}" is visible in the list|
  macro %Q|I wait for some seconds|
  macro %Q|I choose print button|
  macro %Q|I delete printer simulater generated files|
  macro %Q|I wait for some seconds|
    i = i+1
    end
end
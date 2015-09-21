Given(/^I am on the "(.*?)" Screen$/) do |screen_name|
    @current_page = page_by_name(screen_name)
    @current_page.navigate
    sleep(STEP_PAUSE)
end


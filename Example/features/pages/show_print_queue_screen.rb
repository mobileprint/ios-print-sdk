require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class ShowPrintQueueScreen < Calabash::IBase

  def trait
    screen_title
  end

  def screen_title
    "label marked:'Share Item"
  end


  def navigate
    unless current_page?
         share_screen = go_to(ShareScreen)
        sleep(WAIT_SCREENLOAD)
      touch share_screen.print_queue
    uia_tap_mark("Allow")
    uia_tap_mark("Ok")
    end
    await
  end

end















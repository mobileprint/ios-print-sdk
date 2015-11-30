require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class ShareItemScreen < Calabash::IBase

  def trait
    screen_title
    "label marked:'Cancel'"
  end

  def screen_title
    "label marked:'Share Item"
  end


  def navigate
    unless current_page?
         print_pod_screen = go_to(PrintPodScreen)
        sleep(WAIT_SCREENLOAD)
      touch print_pod_screen.share_item
    end
    await
  end

end















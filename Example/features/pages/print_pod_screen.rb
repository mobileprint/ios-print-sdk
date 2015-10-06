require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class PrintPodScreen < Calabash::IBase

  def trait
      screen_title
  end

  def screen_title
    "label marked:'Print Pod"
  end
    
  def share_icon
    touch("view marked:'Share'")
  end
       
  def navigate
        await
      end

end















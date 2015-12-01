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
    "view marked:'Share'"
  end
  def share_item
        "view marked:'Share Item'"
    end
    def configure_direct_print
       query("view marked:'Configure'")[0]
    end
    def print_client_ui
        "* id:'printIcon'"
        end
    def print_queue_client_ui
        "* id:'printLaterIcon'"
        end
       
  def navigate
        await
      end

end















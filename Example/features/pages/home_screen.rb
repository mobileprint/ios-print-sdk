require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class HomeScreen < Calabash::IBase

  def trait
      screen_title
  end

  def screen_title
    "label marked:'Print Pod"
  end

       
  def navigate
        await
      end

end















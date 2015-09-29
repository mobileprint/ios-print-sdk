require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class DirectPrintItemScreen < Calabash::IBase

  def trait
    screen_title
  end

  def screen_title
    "label marked:'Direct Print Item"
  end


  def navigate
    await
  end

end















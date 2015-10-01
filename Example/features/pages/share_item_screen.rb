require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class ShareItemScreen < Calabash::IBase

  def trait
    screen_title
  end

  def screen_title
    "label marked:'Share Item"
  end


  def navigate
    await
  end

end















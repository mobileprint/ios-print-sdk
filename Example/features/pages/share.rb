require 'calabash-cucumber/ibase'

class ShareScreen < Calabash::IBase

  def trait
    mail
    print
    #save_to_camera
    #print_queue
  end

  def mail
  "view marked:'Mail'"
  end

 def print
   "view marked:'Print'"
 end

  def save_to_camera
    "view marked:'Save to Camera Roll'"
  end

  def share_icon
    "view marked:'Share.png'"
  end

  def print_queue
    "view marked:'Print Queue'"
  end


  def navigate
      unless current_page?
          print_pod_screen = go_to(PrintPodScreen)
        sleep(WAIT_SCREENLOAD)
      touch print_pod_screen.share_icon
    end
    await
  end



end
require "calabash-cucumber/ibase"

  class BaseHtmlScreen < Calabash::IBase



    def button (button_text)
        "webView css:'button' {textContent LIKE '#{button_text}'}"
    end

    def button_with_id (button_id)
        "webView css:'button##{button_id}'"
    end



  end



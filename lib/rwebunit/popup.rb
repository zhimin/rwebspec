module RWebUnit
  module Popup

    #= Popup
    #

    # Start background thread to click popup windows
    #  Warning:
    #    Make browser window active
    #    Don't mouse your mouse to focus other window during test execution
    def check_for_popups
      autoit = WIN32OLE.new('AutoItX3.Control')
      #
      # Do forever - assumes popups could occur anywhere/anytime in your
      # application.
      loop do
        # Look for window with given title. Give up after 1 second.
        ret = autoit.WinWait('Windows Internet Explorer', '', 1)
        #
        # If window found, send appropriate keystroke (e.g. {enter}, {Y}, {N}).
        if (ret==1) then
          autoit.Send('{enter}')
        end
        #
        # Take a rest to avoid chewing up cycles and give another thread a go.
        # Then resume the loop.
        sleep(3)
      end
    end

    ##
    #  Check for "Security Information" and "Security Alert" alert popup, click 'Yes'
    #
    # Usage: For individual test suite
    #
    # before(:all) do
    #  $popup = Thread.new { check_for_alerts }
    #  open_in_browser
    #  ...
    # end
    #
    # after(:all) do
    #   close_browser
    #   Thread.kill($popup)
    # end
    #
    # or for all tests,
    #  $popup = Thread.new { check_for_alerts }
    #  at_exit{ Thread.kill($popup) }
    def check_for_security_alerts
      autoit = WIN32OLE.new('AutoItX3.Control')
      loop do
        ["Security Alert", "Security Information"].each do |win_title|
          ret = autoit.WinWait(win_title, '', 1)
          if (ret==1) then
            autoit.Send('{Y}')
          end
        end
        sleep(3)
      end
    end

    def verify_alert(title = "Microsoft Internet Explorer", button = "OK")
      if is_windows? && !is_firefox?
        WIN32OLE.new('AutoItX3.Control').ControlClick(title, '', button)
      else
        raise "This function only supports IE"
      end
    end

    def click_button_in_security_information_popup(button = "&Yes")
      verify_alert("Security Information", "", button)
    end
    alias click_security_information_popup click_button_in_security_information_popup

    def click_button_in_security_alert_popup(button = "&Yes")
      verify_alert("Security Alert", "", button)
    end
    alias click_security_alert_popup click_button_in_security_alert_popup

    def click_button_in_javascript_popup(button = "OK")
      verify_alert()
    end
    alias click_javascript_popup click_button_in_javascript_popup

    ##
    # This only works for IEs
    #   Cons:
    #     - Slow
    #     - only works in IE
    #     - does not work for security alert ?
    def ie_popup_clicker(button_name = "OK", max_wait = 15)
      require 'watir/contrib/enabled_popup'
      require 'win32ole'
      hwnd = ie.enabled_popup(15)
      if (hwnd)  #yeah! a popup
        popup = WinClicker.new
        popup.makeWindowActive(hwnd) #Activate the window.
        popup.clickWindowsButton_hwnd(hwnd, button_name) #Click the button
        #popup.clickWindowsButton(/Internet/,button_name,30)
        popup = nil
      end
    end

    def click_popup_window(button, wait_time= 9, user_input=nil )
      @web_browser.start_clicker(button, wait_time, user_input)
      sleep 0.5
    end
    # run a separate process waiting for the popup window to click
    #
    #
    def prepare_to_click_button_in_popup(button = "OK", wait_time = 3)
      #  !@web_browser.is_firefox?
      # TODO: firefox is OK
      if RUBY_PLATFORM =~ /mswin/  then
        start_checking_js_dialog(button, wait_time)
      else
        raise "this only support on Windows and on IE"
      end
    end

    # Start a background process to click the button on a javascript popup window
    def start_checking_js_dialog(button = "OK", wait_time = 3)
      w = WinClicker.new
      longName = File.expand_path(File.dirname(__FILE__)).gsub("/", "\\" )
      shortName = w.getShortFileName(longName)
      c = "start ruby #{shortName}\\clickJSDialog.rb #{button} #{wait_time} "
      w.winsystem(c)
      w = nil
    end

    # Click the button in javascript popup dialog
    # Usage:
    #   click_button_in_popup_after { click_link('Cancel')}
    #   click_button_in_popup_after("OK") { click_link('Cancel')}
    #
    def click_button_in_popup_after(options = {:button => "OK", :wait_time => 3}, &block)
      if is_windows?  then
        start_checking_js_dialog(options[:button], options[:wait_time])
        yield
      else
        raise "this only support on Windows and on IE"
      end
    end

  end
end

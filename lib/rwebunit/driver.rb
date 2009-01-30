# convenient methods to drive the browser.
#
# Instead of
#    browser.click_button("submit")
# You can just use
#    click_button("submit")
#
require File.join(File.dirname(__FILE__), 'itest_plugin')
require 'timeout'

module RWebUnit
  module Driver
    include RWebUnit::ITestPlugin

    # open a browser, and set base_url via hash, but does not acually
    #
    # example:
    #   open_browser :base_url => http://localhost:8080
    #
    # There are 3 ways to set base url 
    #   1. pass as first argument
    #   2. If running using iTest2, used as confiured
    #   3. Use default value set
    def open_browser(base_url = nil, options = {})
      base_url ||= $ITEST2_PROJECT_BASE_URL
      base_url ||= $BASE_URL 
      raise "base_url must be set" if base_url.nil?
      
      default_options = {:speed => "fast",
        :visible => true,
        :highlight_colour => 'yellow',
        :close_others => true,
        :start_new => false, 	# start a new browser always
        :go => true}

      options = default_options.merge options
      options[:firefox] = true if "Firefox" == $ITEST2_BROWSER || "Firefox" == $BROWSER
      ($ITEST2_HIDE_BROWSER) ? $HIDE_IE = true : $HIDE_IE = false

      uri = URI.parse(base_url)
      uri_base = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      if options[:start_new]
        @web_browser = WebBrowser.new(uri_base, nil, options)
      else 
        # Reuse existing browser
        @web_browser = WebBrowser.reuse(uri_base, options)
      end

      if options[:go]
        (uri.path.length == 0) ?  begin_at("/") :  begin_at(uri.path)
      end
      return @web_browser
    end
    alias open_browser_with open_browser
    
    def browser
      @web_browser
    end

    # Verify the next page following an operation.
    #
    # Typical usage:
    #   login_page.click_login
    #   expect_page HomePage
    def expect_page(page_clazz, argument = nil)
      if argument
        page_clazz.new(@web_browser, argument)
      else
        page_clazz.new(@web_browser)
      end
    end

    # Using Ruby block syntax to create interesting domain specific language,
    # may be appeal to someone.

    # Example:
    #  on @page do |i|
    #    i.enter_text('btn1')
    #    i.click_button('btn1')
    #  end
    def on(page, &block)
      yield page
    end

    # fail the test if user can perform the operation
    #
    # Example:
    #  shall_not_allow { 1/0 }
    def shall_not_allow(&block)
      operation_performed_ok = false
      begin
        yield
        operation_performed_ok  = true
      rescue
      end
      raise "Operation shall not be allowed" if operation_performed_ok
    end
    alias do_not_allow shall_not_allow

    def allow(&block)
      operation_performed_ok = false
      begin
        yield
        operation_performed_ok  = true
      rescue
      end
      operation_performed_ok
    end

    # try operation, ignore if errors occur
    #
    # Example:
    #   failsafe { click_link("Logout") }  # try logout, but it still OK if not being able to (already logout))
    def failsafe(&block)
      begin
        yield
      rescue =>e
      end
    end
    alias fail_safe failsafe

    def context
      @web_browser.context
    end

    def begin_at(url)
      dump_caller_stack
      @web_browser.begin_at(url)
    end

    def ie
      @web_browser.ie
    end

    def is_firefox?
      @web_browser.is_firefox? if @web_browser
    end

    def firefox
      @web_browser.firefox
    end

    def close_browser
      if @web_browser
        @web_browser.close_browser unless $ITEST2_LEAVE_BROWSER_OPEN_AFTER_RUN
      else
        WebBrowser.close_all_browsers
      end
    end
    alias close_ie close_browser


    def goto_page(page)
      operation_delay
      dump_caller_stack
      @web_browser.goto_page(page) if @web_browser
    end
    alias visit goto_page

    def attach_browser(how, what, options = {})
      options.merge!(:browser => is_firefox? ? "Firefox" : "IE")
      begin
        options.merge!(:base_url => browser.context.base_url)
      rescue => e
        puts "error to attach to browser: #{e}"
      end
      WebBrowser.attach_browser(how, what, options)
    end

    ##
    #  Delegate to WebTester
    #

    # Depends on which object type, you can use following attribute
    # More details: http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # :id 	 Used to find an element that has an "id=" attribute. Since each id should be unique, according to the XHTML specification, this is recommended as the most reliable method to find an object. *
    # :name 	Used to find an element that has a "name=" attribute. This is useful for older versions of HTML, but "name" is deprecated in XHTML. *
    # :value 	Used to find a text field with a given default value, or a button with a given caption, or a text field
    # :text 	Used for links, spans, divs and other element that contain text.
    # :index 	Used to find the nth element of the specified type on a page. For example, button(:index, 2) finds the second button. Current versions of WATIR use 1-based indexing, but future versions will use 0-based indexing.
    # :class 	Used for an element that has a "class=" attribute.
    # :title 	Used for an element that has a "title=" attribute.
    # :xpath 	Finds the item using xpath query.
    # :method 	Used only for forms, the method attribute of a form is either GET or POST.
    # :action 	Used only for form elements, specifies the URL where the form is to be submitted.
    # :href 	Used to identify a link by its "href=" attribute.
    # :src 	Used to identify an image by its URL.
    #

    # area 	<area> tags
    # button 	<input> tags with type=button, submit, image or reset
    # check_box 	<input> tags with type=checkbox
    # div 	<div> tags
    # form 	<form> tags
    # frame 	frames, including both the <frame> elements and the corresponding pages
    # h1 - h6 	<h1>, <h2>, <h3>, <h4>, <h5>, <h6> tags
    # hidden 	<input> tags with type=hidden
    # image 	<img> tags
    # label 	<label> tags (including "for" attribute)
    # li 	<li> tags
    # link 	<a> (anchor) tags
    # map 	<map> tags
    # radio 	<input> tags with the type=radio; known as radio buttons
    # select_list 	<select> tags, known as drop-downs or drop-down lists
    # span 	<span> tags
    # table 	<table> tags, including row and cell methods for accessing nested elements
    # text_field 	<input> tags with the type=text (single-line), type=textarea (multi-line), and type=password
    # p 	<p> (paragraph) tags, because
    [:area, :button, :cell, :checkbox, :div, :form, :frame, :h1, :h2, :h3, :h4, :h5, :h6, :hidden, :image, :li, :link, :map, :pre, :row, :radio, :select_list, :span, :table, :text_field, :paragraph, :file_field, :label].each do |method|
      define_method method do |*args|
        dump_caller_stack
        # add check for @web_browser, in case the moudule included without init browser
        @web_browser.send(method, *args) if @web_browser
      end
    end
    alias td cell
    alias check_box checkbox  # seems watir doc is wrong, checkbox not check_box
    alias tr row

    [:back, :forward, :refresh].each do |method|
      define_method(method) do
        dump_caller_stack
        @web_browser.send(method)  if @web_browser
      end
    end
    alias refresh_page refresh
    alias go_back back
    alias go_forward forward

    [:images, :links, :buttons, :select_lists, :checkboxes, :radios, :text_fields].each do |method|
      define_method method do
        dump_caller_stack
        @web_browser.send(method)  if @web_browser
      end
    end

    # Check one or more checkboxes with same name, can accept a string or an array of string as values checkbox, pass array as values will try to set mulitple checkboxes.
    #
    # page.check_checkbox('bad_ones', 'Chicken Little')
    # page.check_checkbox('good_ones', ['Cars', 'Toy Story'])
    #
    [:set_form_element, :click_link_with_text, :click_link_with_id, :submit, :click_button_with_id, :click_button_with_caption, :click_button_with_value, :click_radio_option, :clear_radio_option, :select_file_for_upload, :check_checkbox, :uncheck_checkbox, :select_option].each do |method|
      define_method method do |*args|
        dump_caller_stack
        operation_delay
        @web_browser.send(method, *args)  if @web_browser
      end
    end

    alias enter_text set_form_element
    alias click_link click_link_with_text
    alias click_button_with_text click_button_with_caption
    alias click_button click_button_with_caption
    alias click_radio_button click_radio_option
    alias clear_radio_button clear_radio_option

    # for text field can be easier to be identified by attribute "id" instead of "name", not recommended though
    def enter_text_with_id(textfield_id, value)
      dump_caller_stack
      operation_delay
      text_field(:id, textfield_id).set(value)
    end

    def contains_text(text)
      @web_browser.contains_text(text);
    end

    def click_button_with_image_src_contains(image_filename)
      dump_caller_stack
      operation_delay
      found = nil
      raise "no buttons in this page" if buttons.length <= 0
      buttons.each { |btn|
        if btn && btn.src  && btn.src.include?(image_filename) then
          found = btn
          break
        end
      }
      raise "not image button with src: #{image_filename} found" if found.nil?
      found.click
    end
    alias click_button_with_image click_button_with_image_src_contains

    def new_popup_window(options)
      @web_browser.new_popup_window(options)
    end

    # Wait for specific seconds for an Ajax update finish.
    # Trick: In your Rails application,
    #     :loading 	=> "Element.show('search_indicator');
    #     :complete	=> "Element.hide('search_indicator');
    #
    #   <%= image_tag("indicator.gif", :id => 'search_indicator', :style => 'display:none') %>
    #
    # Typical usage:
    #    ajax_wait_for_element("search_indicator", 30)
    #    ajax_wait_for_element("search_indicator", 30, "show")
    #    ajax_wait_for_element("search_indicator", 30, "hide")
    #    ajax_wait_for_element("search_indicator", 30, "show", 5) # check every 5 seconds
    #
    # Warning: this method has not been fully tested, if you are not using Rails, change your parameter accordingly.
    #
    def ajax_wait_for_element(element_id, seconds, status='show', check_interval=2)
      count = 0
      check_interval = 1 if check_interval < 1 or check_interval > seconds
      while count < (seconds / check_interval) do
        search_indicator = @web_browser.element_by_id(element_id)
        search_indicator_outer_html = search_indicator.outerHtml if search_indicator
        if status == 'hide'
          return true if search_indicator_outer_html and !search_indicator_outer_html.include?('style="DISPLAY: none"')
        else
          return true if search_indicator_outer_html and search_indicator_outer_html.include?('style="DISPLAY: none"')
        end
        sleep check_interval if check_interval > 0 and check_interval < 5 * 60 # wait max 5 minutes
        count += 1
      end
      return false
    end

    def wait_for_element(element_id, timeout = 30, interval = 0.5)
      start_time = Time.now
      until @web_browser.element_by_id(element_id) do
        sleep(interval)
        if (Time.now - start_time) > timeout
          raise RuntimeError, "failed to find element: #{element_id} for max #{timeout}"
        end
      end
    end

    # TODO: Firewatir does not suport retrieving style or outerHtml
    #    http://jira.openqa.org/browse/WTR-260
    #    http://code.google.com/p/firewatir/issues/detail?id=76
    #
    # Max timeout value is 10 minutes
    #
    def ajax_call_complete_after_element_hidden(elem_id, check_start = 0.5, timeout = 5, interval = 0.5, &block)
      yield
      sleep check_start  # the time allowed to perform the coomplete
      timeout = 10 * 60 if timeout > 10 * 600 or timeout <= 0
      begin
        Timeout::timeout(timeout) {
          begin
            elem = element_by_id(elem_id)
            while elem  do
              puts "outer=>#{elem.outerHtml}|"
              puts "style =>#{elem.attribute_value('style')}|"
              sleep interval
              elem = element_by_id(elem_id)
            end
          rescue => e
            puts e
          end
        }
      rescue Timeout::Error
        # Too slow!!
        raise "Too slow, wait max #{timeout} seconds, the element #{elem_id} still there"
      end
    end

    # Warning: this does not work well with Firefox yet.
    def element_text(elem_id)
      @web_browser.element_value(elem_id)
    end

    def element_by_id(elem_id)
      @web_browser.element_by_id(elem_id)
    end

    # ---
    # For debugging
    # ---
    def dump_response(stream = nil)
      @web_browser.dump_response(stream)
    end

    def save_current_page(to_dir = ENV['TEMP_DIR'] || "C:\\temp")
      Dir.mkdir(to_dir) unless File.exists?(to_dir)
      file_name = Time.now.strftime("%m%d%H%M%S") + ".html"
      file = File.join(to_dir, file_name)
      File.new(file, "w").puts page_source
    end

    def click_popup_window(button, wait_time= 9, user_input=nil )
      @web_browser.start_clicker(button, wait_time, user_input)
      sleep 0.5
    end

    # return plain text view of page
    def page_text
      @browser.text
    end

    def label_with_id(label_id)
      label(:id, label_id).text
    end

    def span_with_id(span_id)
      span(:id, span_id).text
    end

    def cell_with_id(cell_id)
      cell(:id, cell_id).text
    end
    alias table_data_with_id cell_with_id

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
      if RUBY_PLATFORM =~ /mswin/  then
        start_checking_js_dialog(options[:button], options[:wait_time])
        yield
      else
        raise "this only support on Windows and on IE"
      end
    end


    # Support of iTest to ajust the intervals between keystroke/mouse operations
    def operation_delay
      begin
        if $ITEST2_OPERATION_DELAY && $ITEST2_OPERATION_DELAY > 0 &&
          $ITEST2_OPERATION_DELAY && $ITEST2_OPERATION_DELAY < 30000  then # max 30 seconds
            sleep($ITEST2_OPERATION_DELAY / 1000)
          end

          while $ITEST2_PAUSE
            debug("Paused, waiting ...")
            sleep 1
          end
        rescue => e
          puts "Error on delaying: #{e}"
          # ignore
        end
      end


      def close_all_browsers
        Watir::IE.close_all
      end

      def is_mac?
        RUBY_PLATFORM.downcase.include?("darwin")
      end

      def is_windows?
        RUBY_PLATFORM.downcase.include?("mswin")
      end

      def is_linux?
        RUBY_PLATFORM.downcase.include?("linux")
      end

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

      ##
      #  Convert :first to 1, :second to 2, and so on...
      def symbol_to_sequence(symb)
        value = { :zero => 0, :first => 1, :second => 2, :third => 3,
          :fourth => 4, :fifth => 5, :sixth => 6, :seventh => 7,
        :eighth => 8, :ninth => 9, :tenth => 10 }[symb]
        return value || symb.to_i
      end

    end
  end

#***********************************************************
#* Copyright (c) 2006, Zhimin Zhan.
#* Distributed open-source, see full license in MIT-LICENSE
#***********************************************************

begin
  require "selenium-webdriver"
rescue LoadError => e
  raise "You have must at least WebDriver installed"
end

require File.join(File.dirname(__FILE__), "element_locator.rb")

module RWebSpec
  
    class WebBrowser

      include ElementLocator

      attr_accessor :context

      def initialize(base_url = nil, existing_browser = nil, options = {})
        default_options = {:speed => "zippy",
          :visible => true,
          :highlight_colour => 'yellow',
          :close_others => true
        }
        options = default_options.merge options
        @context = Context.new base_url if base_url
        
        options[:browser] ||= "ie" if RUBY_PLATFORM =~ /mingw/
        case options[:browser].to_s.downcase
          when "firefox"
            initialize_firefox_browser(existing_browser, base_url, options)
          when "chrome"
            initialize_chrome_browser(existing_browser, base_url, options)
          when "ie"
            initialize_ie_browser(existing_browser, options)
          when  "htmlunit"
             initialize_htmlunit_browser(base_url, options)
        end
      end

      def initialize_firefox_browser(existing_browser, base_url, options)
        if existing_browser then
          @browser = existing_browser
          return
        end

        @browser = Selenium::WebDriver.for :firefox
        @browser.navigate.to base_url
      end

      def initialize_chrome_browser(existing_browser, base_url, options)
        if existing_browser then
          @browser = existing_browser
          return
        end

        @browser = Selenium::WebDriver.for :chrome
        @browser.navigate.to base_url
      end

      def initialize_htmlunit_browser(base_url, options)
        puts "XXXXX start HtmlUnit..."
        require 'json'
        caps = Selenium::WebDriver::Remote::Capabilities.htmlunit(:javascript_enabled => false)        
        client = Selenium::WebDriver::Remote::Http::Default.new
        # client.proxy = Selenium::WebDriver::Proxy.new(:http => "web-proxy.qdot.qld.gov.au:3128")
        
        @browser = Selenium::WebDriver.for(:remote, :http_client => client , :desired_capabilities => caps)         
        if options[:go] 
          @browser.navigate.to(base_url) 
        end
      end

      def initialize_ie_browser(existing_browser, options)
        if existing_browser then
          @browser = existing_browser
          if $TESTWISE_EMULATE_TYPING && $TESTWISE_TYPING_SPEED then
            @browser.set_slow_speed if $TESTWISE_TYPING_SPEED == 'slow'
            @browser.set_fast_speed if $TESTWISE_TYPING_SPEED == 'fast'
          else
            @browser.speed = :zippy
          end
          return
        end

        @browser = Selenium::WebDriver.for :ie
        #      if $TESTWISE_EMULATE_TYPING && $TESTWISE_TYPING_SPEED then
        #        @browser.set_slow_speed if $TESTWISE_TYPING_SPEED == 'slow'
        #        @browser.set_fast_speed if $TESTWISE_TYPING_SPEED == 'fast'
        #      else
        #        @browser.speed = :zippy
        #      end
        #      @browser.activeObjectHighLightColor = options[:highlight_colour]
        #      @browser.visible = options[:visible] unless $HIDE_IE
        #      #NOTE: close_others fails
        #      if RUBY_VERSION =~ /^1\.8/ && options[:close_others] then
        #        @browser.close_others
        #      else
        #        puts "close other browser instances not working yet in Ruby 1.9.1 version of Watir"
        #      end
      end

      # TODO resuse not working yet
      def self.reuse(base_url, options)
        if self.is_windows? && $TESTWISE_BROWSER != "Firefox"
          Watir::IE.each do |browser_window|
            return WebBrowser.new(base_url, browser_window, options)
          end
          #puts "no browser instance found"
          WebBrowser.new(base_url, nil, options)
        else
          WebBrowser.new(base_url, nil, options)
        end
      end

      # for popup windows
      def self.new_from_existing(underlying_browser, web_context = nil)
        return WebBrowser.new(web_context ? web_context.base_url : nil, underlying_browser, {:close_others => false})
      end

      def find_element(* args)
        @browser.send("find_element", *args)
      end

      def find_elements(* args)
        @browser.send("find_elements", *args)
      end

      ##
      #  Delegate to WebDriver
      #
      [:button, :cell, :checkbox, :div, :form, :frame, :h1, :h2, :h3, :h4, :h5, :h6, :hidden, :image, :li, :link, :map, :pre, :row, :radio, :select_list, :span, :table, :text_field, :paragraph, :file_field, :label].each do |method|
        tag_name = method
        define_method method do |* args|
          if args.size == 2 then
            find_element(args[0].to_sym, args[1])
          end
        end
      end
      alias td cell
      alias check_box checkbox # seems watir doc is wrong, checkbox not check_box
      alias tr row

      # Wrapp of Watir's area to support Firefox and Watir
      #
      # Note: FireWatir does not support area directly, treat it as text_field
      def area(* args)
        if is_firefox?
          text_field(* args)
        else
          @browser.send("area", * args)
        end
      end

      def modal_dialog(how=nil, what=nil)
        @browser.modal_dialog(how, what)
      end

      # This is the main method for accessing a generic element with a given attibute
      #  *  how   - symbol - how we access the element. Supports all values except :index and :xpath
      #  *  what  - string, integer or regular expression - what we are looking for,
      #
      # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
      #
      # returns an Watir::Element object
      #
      # Typical Usage
      #
      #   element(:class, /foo/)      # access the first element with class 'foo'. We can use a string in place of the regular expression
      #   element(:id, "11")          # access the first element that matches an id
      def element(how, what)
        return @browser.element(how, what)
      end

      # this is the main method for accessing generic html elements by an attribute
      #
      # Returns a HTMLElements object
      #
      # Typical usage:
      #
      #   elements(:class, 'test').each { |l| puts l.to_s }  # iterate through all elements of a given attribute
      #   elements(:alt, 'foo')[1].to_s                       # get the first element of a given attribute
      #   elements(:id, 'foo').length                        # show how many elements are foung in the collection
      #
      def elements(how, what)
        return @browser.elements(how, what)
      end

      def show_all_objects
        @browser.show_all_objects
      end

      # Returns the specified ole object for input elements on a web page.
      #
      # This method is used internally by Watir and should not be used externally. It cannot be marked as private because of the way mixins and inheritance work in watir
      #
      #   * how - symbol - the way we look for the object. Supported values are
      #                  - :name
      #                  - :id
      #                  - :index
      #                  - :value etc
      #   * what  - string that we are looking for, ex. the name, or id tag attribute or index of the object we are looking for.
      #   * types - what object types we will look at.
      #   * value - used for objects that have one name, but many values. ex. radio lists and checkboxes
      def locate_input_element(how, what, types, value=nil)
        @browser.locate_input_element(how, what, types, value)
      end

      # This is the main method for accessing map tags - http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/map.asp?frame=true
      #  *  how   - symbol - how we access the map,
      #  *  what  - string, integer or regular expression - what we are looking for,
      #
      # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
      #
      # returns a map object
      #
      # Typical Usage
      #
      #   map(:id, /list/)                 # access the first map that matches list.
      #   map(:index,2)                    # access the second map on the page
      #   map(:title, "A Picture")         # access a map using the tooltip text. See http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/title_1.asp?frame=true
      #
      def map(how, what=nil)
        @browser.map(how, what)
      end

      def contains_text(text)
        @browser.contains_text(text);
      end

      # return HTML of current web page
      def page_source
        @browser.page_source
      end
      alias html_body page_source
      alias html page_source

      def page_title
        @browser.title
      end

      def text(squeeze_spaces = true)
				@browser.find_element(:tag_name, "body").text
      end

			# @deprecated
			def text_with_sanitize				
				begin
					require 'sanitize'
        	page_text_string = Sanitize.clean(html)
					page_text_string = page_text_string.squeeze(" ") if squeeze_spaces
						# remove duplicated (spaces)
					return page_text_string
				rescue => e
					puts "failed to santize html source => text, #{e}"
					return @browser.html
				end
			end
			
      [:images, :links, :buttons, :select_lists, :checkboxes, :radios, :text_fields, :divs, :dls, :dds, :dts, :ems, :lis, :maps, :spans, :strongs, :ps, :pres, :labels].each do |method|
        define_method method do
          @browser.send(method)
        end
      end

      # current url
      def current_url
        @browser.current_url
      end
      alias url current_url

      def base_url=(new_base_url)
        if @context
          @conext.base_url = new_base_url
          return
        end
        @context = Context.new base_url
      end

      def driver
        @browser
      end
      
      def underlying_browser
        @browser
      end

      def is_ie?
        @browser.browser.to_s == "ie"
      end

      def is_firefox?
        @browser.browser.to_s == "firefox"
      end

      # Close the browser window.  Useful for automated test suites to reduce
      # test interaction.
      def close_browser
        @browser.quit
        sleep 1
      end
      alias close close_browser

      #TODO determine browser type, check FireWatir support or not
      def self.close_all_browsers
        raise "not implemented"
      end

      def full_url(relative_url)
        if @context && @context.base_url
          @context.base_url + relative_url
        else
          relative_url
        end
      end

      # Crahses where http:///ssshtttp:///
      def begin_at(relative_url)
        if relative_url =~ /\s*^http/
          @browser.navigate.to relative_url
        else
          @browser.navigate.to full_url(relative_url)
        end
      end

      def browser_opened?
        begin
          @browser != nil
        rescue => e
          return false
        end
      end

      # Some browsers (i.e. IE) need to be waited on before more actions can be
      # performed.  Most action methods in Watir::Simple already call this before
      # and after.
      def wait_for_browser
        # NOTE: no need any more
      end


      # A convenience method to wait at both ends of an operation for the browser
      # to catch up.
      def wait_before_and_after
        wait_for_browser
        yield
        wait_for_browser
      end


      [:focus, :close_others].each do |method|
        define_method(method) do
          @browser.send(method)
        end
      end

      def forward
        @browser.navigate().forward
      end
      alias go_forward forward

      # TODO can't browse back if on invalid page
      def back
        @browser.navigate.back
      end
      alias go_back back

      def refresh
        @browser.navigate().refresh
      end
      alias refresh_page refresh

      # Go to a page
      #  Usage:
      #    open_browser("http://www.itest2.com"
      #    ....
      #    goto_page("/purchase")  # full url => http://www.itest.com/purchase
      def goto_page(page)
        goto_url full_url(page);
      end

      # Go to a URL directly
      #  goto_url("http://www.itest2.com/downloads")
      def goto_url(url)
        @browser.navigate.to url
      end

      # text fields
      def enter_text_into_field_with_name(name, text)
        the_element = find_element(:name, name)
        if the_element.tag_name == "input" || the_element.tag_name == "textarea" then
          the_element.clear
          the_element.send_keys(text)
        else
          elements = find_elements(:name, name)
          if elements.size == 1 then
            elements[0].send_keys(text)
          else
            element_set = elements.select {|x| x.tag_name == "textarea" || (x.tag_name == "input" &&  x.attribute("text")) }
            element_set[0].send_keys(text)
          end
        end
        return true
      end

      alias set_form_element enter_text_into_field_with_name
      alias enter_text enter_text_into_field_with_name
      alias set_hidden_field set_form_element

      #links
      def click_link_with_id(link_id, opts = {})
        if opts && opts[:index]
          elements = find_elements(:id, link_id)
          elements[opts[:index]-1].click
        else
          find_element(:id, link_id).click
        end
      end

      ##
      # click_link_with_text("Login")
      # click_link_with_text("Show", :index => 2)
      def click_link_with_text(link_text, opts = {})
        if opts && opts[:index]
          elements = find_elements(:link_text, link_text)
          elements[opts[:index]-1].click
        else
          find_element(:link_text, link_text).click
        end
      end
      alias click_link click_link_with_text


      # Click a button with give HTML id
      # Usage:
      #   click_button_with_id("btn_sumbit")
      def click_button_with_id(id, opts = {})
        find_element(:id, id).click
      end

      # Click a button with give name
      # Usage:
      #   click_button_with_name("confirm")
      #   click_button_with_name("confirm", :index => 2)
      def click_button_with_name(name, opts={})
        find_element(:name, name).click
      end

      # Click a button with caption
      #
      # TODO: Caption is same as value
      #
      # Usage:
      #   click_button_with_caption("Confirm payment")
      def click_button_with_caption(caption, opts={})
        all_buttons = button_elements
        matching_buttons = all_buttons.select{|x| x.attribute('value') == caption}
        if matching_buttons.size > 0

          if opts && opts[:index]
            puts "Call matching buttons: #{matching_buttons.inspect}"
            first_match = matching_buttons[opts[:index].to_i() - 1]
            first_match.click
          end

          the_button = matching_buttons[0]
          the_button.click

        else
          raise "No button with value: #{caption} found"
        end
      end
      alias click_button click_button_with_caption
      alias click_button_with_text click_button_with_caption


      #   click_button_with_caption("Confirm payment")
      def click_button_with_value(value, opts={})
        all_buttons = button_elements
        if opts && opts[:index]
          all_buttons.select{|x| x.attribute('value') == caption}[index]
        else
          all_buttons.each do |button|
            if button.attribute('value') == value then
              button.click
              return
            end
          end
        end
      end

      # Click image buttion with image source name
      #
      # For an image submit button <input name="submit" type="image" src="/images/search_button.gif">
      #  click_button_with_image("search_button.gif")
      def click_button_with_image_src_contains(image_filename)
        all_buttons = button_elements
        found = nil
        all_buttons.select do |x|
          if x["src"] =~ /#{Regexp.escape(image_filename)}/
            found = x
            break
          end
        end

        raise "not image button with src: #{image_filename} found" if found.nil?
        found.click
      end

      alias click_button_with_image click_button_with_image_src_contains
      # Select a dropdown list by name
      # Usage:
      #   select_option("country", "Australia")
      def select_option(selectName, text)	
				Selenium::WebDriver::Support::Select.new(find_element(:name, selectName)).select_by(:text, text)
      end

      # submit first submit button
      def submit(buttonName = nil)
        if (buttonName.nil?) then
          buttons.each { |button|
            next if button.type != 'submit'
            button.click
            return
          }
        else
          click_button_with_name(buttonName)
        end
      end

      # Check a checkbox
      # Usage:
      #   check_checkbox("agree")
      #   check_checkbox("agree", "true")
      def check_checkbox(checkBoxName, values=nil)
        if values
          values.class == Array ? arys = values : arys = [values]
          elements = find_elements(:name, checkBoxName)
          the_checkbox = elements[0] if elements.size == 1
          if the_checkbox
            the_checkbox.click unless the_checkbox.selected?
            return
          end

          arys.each { |cbx_value|
            elements.each do |elem|
              elem.click if elem.attribute('value') == cbx_value && !elem.selected?
            end
          }
        else
          the_checkbox = find_element(:name, checkBoxName)
          the_checkbox.click unless the_checkbox.selected?
        end
      end

      # Check a checkbox
      # Usage:
      #   uncheck_checkbox("agree")
      #   uncheck_checkbox("agree", "false")
      def uncheck_checkbox(checkBoxName, values = nil)
        if values
          values.class == Array ? arys = values : arys = [values]
          elements = find_elements(:name, checkBoxName)
          the_checkbox = elements[0] if elements.size == 1
          if the_checkbox
            the_checkbox.click if the_checkbox.selected?
            return
          end

          arys.each { |cbx_value|
            elements.each do |elem|
              elem.click if elem.attribute('value') == cbx_value && the_checkbox && the_checkbox.selected?
            end
          }
        else
          the_checkbox = find_element(:name, checkBoxName)
          the_checkbox.click if the_checkbox.selected?
        end
      end


      # Click a radio button
      #  Usage:
      #    click_radio_option("country", "Australia")
      def click_radio_option(radio_group, radio_option)
        the_radio_button = find_element(:xpath, "//input[@type='radio' and @name='#{radio_group}' and @value='#{radio_option}']")
        the_radio_button.click
      end
      alias click_radio_button click_radio_option

      # Clear a radio button
      #  Usage:
      #    click_radio_option("country", "Australia")
      def clear_radio_option(radio_group, radio_option)
        the_radio_button = find_element(:xpath, "//input[@type='radio' and @name='#{radio_group}' and @value='#{radio_option}']")
        the_radio_button.clear
      end
      alias clear_radio_button clear_radio_option

      def element_by_id(elem_id)
        @browser.find_element(:id, elem_id)
      end

      def element_value(elementId)
        find_element(:id, elementId).attribute('value')
      end

      def element_source(elementId)
        elem = element_by_id(elementId)
        assert_not_nil(elem, "HTML element: #{elementId} not exists")
        elem.innerHTML
      end

      def select_file_for_upload(file_field, file_path)
        is_on_windows = RUBY_PLATFORM.downcase.include?("mingw") || RUBY_PLATFORM.downcase.include?("mswin")
        normalized_file_path = is_on_windows ? file_path.gsub("/", "\\") : file_path
        file_field(:name, file_field).set(normalized_file_path)
      end

      def start_window(url = nil)
        @browser.start_window(url);
      end

      # Attach to existing browser
      #
      # Usage:
      #    WebBrowser.attach_browser(:title, "iTest2")
      #    WebBrowser.attach_browser(:url, "http://www.itest2.com")
      #    WebBrowser.attach_browser(:url, "http://www.itest2.com", {:browser => "Firefox", :base_url => "http://www.itest2.com"})
      #    WebBrowser.attach_browser(:title, /agileway\.com\.au\/attachment/)  # regular expression
      def self.attach_browser(how, what, options={})
        default_options = {:browser => "IE"}
        options = default_options.merge(options)
        site_context = Context.new(options[:base_url]) if options[:base_url]
        if (options[:browser].to_s == "firefox")
          ff = FireWatir::Firefox.attach(how, what)
          return WebBrowser.new_from_existing(ff, site_context)
        else
          return WebBrowser.new_from_existing(Watir::IE.attach(how, what), site_context)
        end
      end

      # Attach a Watir::IE instance to a popup window.
      #
      # Typical usage
      #   new_popup_window(:url => "http://www.google.com/a.pdf")
      def new_popup_window(options, browser = "ie")
        if is_firefox?
          raise "not implemented"
        else
          if options[:url]
            Watir::IE.attach(:url, options[:url])
          elsif options[:title]
            Watir::IE.attach(:title, options[:title])
          else
            raise 'Please specify title or url of new pop up window'
          end
        end
      end

      # ---
      # For deubgging
      # ---
      def dump_response(stream = nil)
        stream.nil? ? puts(page_source) : stream.puts(page_source)
      end

      # A Better Popup Handler using the latest Watir version. Posted by Mark_cain@rl.gov
      #
      # http://wiki.openqa.org/display/WTR/FAQ#FAQ-HowdoIattachtoapopupwindow%3F
      #
      def start_clicker(button, waitTime= 9, user_input=nil)
        # get a handle if one exists
        hwnd = @browser.enabled_popup(waitTime)
        if (hwnd) # yes there is a popup
          w = WinClicker.new
          if (user_input)
            w.setTextValueForFileNameField(hwnd, "#{user_input}")
          end
          # I put this in to see the text being input it is not necessary to work
          sleep 3
          # "OK" or whatever the name on the button is
          w.clickWindowsButton_hwnd(hwnd, "#{button}")
          #
          # this is just cleanup
          w = nil
        end
      end

      # return underlying browser
      def ie
        @browser.class == "internet_explorer"  ? @browser : nil;
      end

      # return underlying firefox browser object, raise error if not running using Firefox
      def firefox
        is_firefox?  ? @browser : nil;
      end

      def htmlunit
        raise "can't call this as it is configured to use Celerity" unless RUBY_PLATFORM =~ /java/
        @browser
      end

      # Save current web page source to file
      #   usage:
      #      save_page("/tmp/01.html")
      #      save_page()  => # will save to "20090830112200.html"
      def save_page(file_name = nil)
        file_name ||= Time.now.strftime("%Y%m%d%H%M%S") + ".html"
        puts "about to save page: #{File.expand_path(file_name)}" if $DEBUG
        File.open(file_name, "w").puts page_source
      end


      # Verify the next page following an operation.
      #
      # Typical usage:
      #   browser.expect_page HomePage
      def expect_page(page_clazz, argument = nil)
        if argument
          page_clazz.new(self, argument)
        else
          page_clazz.new(self)
        end
      end

      # is it running in MS Windows platforms?
      def self.is_windows?
        RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw")
      end

  end
end

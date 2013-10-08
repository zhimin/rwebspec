#***********************************************************
#* Copyright (c) 2006, Zhimin Zhan.
#* Distributed open-source, see full license in MIT-LICENSE
#***********************************************************


module RWebSpec

  ##
  #  Wrapping WATIR IE and FireWatir Firefox
  #
  class WebBrowser

    attr_accessor :context

    def initialize(base_url = nil, existing_browser = nil, options = {})
      default_options = {:speed => "zippy",
        :visible => true,
        :highlight_colour => 'yellow',
        :close_others => true
      }
      options = default_options.merge options
      @context = Context.new base_url if base_url

      initialize_ie_browser(existing_browser, options)
    end


    def initialize_ie_browser(existing_browser, options)
      @browser = existing_browser ||  Watir::IE.new
      if ($TESTWISE_EMULATE_TYPING && $TESTWISE_TYPING_SPEED) then
        @browser.set_slow_speed if $TESTWISE_TYPING_SPEED == "slow"
        @browser.set_fast_speed if $TESTWISE_TYPING_SPEED == 'fast'
      else
        @browser.speed = :zippy
      end
			
			return if existing_browser

			# Watir-classic 3.4 drop the support			
      # @browser.activeObjectHighLightColor = options[:highlight_colour]
      @browser.visible = options[:visible] unless $HIDE_IE
      #NOTE: close_others fails
			begin
	      if options[:close_others] then
					@browser.windows.reject(&:current?).each(&:close)
	      end
			rescue => e1
				puts "Failed to close others"
			end
    end

    def self.reuse(base_url, options)
      if self.is_windows? && ($TESTWISE_BROWSER != "Firefox" && $TESTWISE_BROWSER != "Firefox")
				require 'watir-classic' 
				# try to avoid 
				#  lib/ruby/1.8/dl/win32.rb:11:in `sym': unknown type specifier 'v'
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


    ##
    #  Delegate to Watir
    #
    [:button, :td, :checkbox, :div, :form, :frame, :h1, :h2, :h3, :h4, :h5, :h6, :hidden, :image, :li, :link, :map, :pre, :tr, :radio, :select_list, :span, :table, :text_field, :paragraph, :file_field, :label].each do |method|
      define_method method do |*args|
        @browser.send(method, *args)
      end
    end
    alias cell td
    alias check_box checkbox  # seems watir doc is wrong, checkbox not check_box
    alias row tr
    alias a link
    alias img image

    def area(*args)
      @browser.send("area", *args)
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
      @browser.html()
      #@browser.document.body
    end
    alias html_body page_source
    alias html page_source


    # return plain text of current web page
    def text
      @browser.text
    end

    def page_title
      case @browser.class.to_s
      when "Watir::IE"
        @browser.document.title
      else
        @browser.title
      end
    end

    [:images, :links, :buttons, :select_lists, :checkboxes, :radios, :text_fields, :divs, :dls, :dds, :dts, :ems, :lis, :maps, :spans, :strongs, :ps, :pres, :labels, :tds, :trs].each do |method|
      define_method method do
        @browser.send(method)
      end
    end
		alias as links
		alias rows trs
		alias cells tds
		alias imgs images
		
    # current url
    def url
      @browser.url
    end

    def base_url=(new_base_url)
      if @context
        @conext.base_url = new_base_url
        return
      end
      @context = Context.new base_url
    end

    def is_firefox?
      return false
    end

    # Close the browser window.  Useful for automated test suites to reduce
    # test interaction.
    def close_browser
      @browser.close
      sleep 2
    end
    alias close close_browser

    def close_all_browsers(browser_type = :ie)      
			@browser.windows.each(&:close)
    end

    def full_url(relative_url)
      if @context && @context.base_url
        @context.base_url + relative_url
      else
        relative_url
      end
    end

    def begin_at(relative_url)
      @browser.goto full_url(relative_url)
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
			  # Watir 3 does not support it any more
        # @browser.waitForIE unless is_firefox?
    end


    # A convenience method to wait at both ends of an operation for the browser
    # to catch up.
    def wait_before_and_after
      wait_for_browser
      yield
      wait_for_browser
    end


    [:back, :forward, :refresh, :focus, :close_others].each do |method|
      define_method(method) do
        @browser.send(method)
      end
    end
    alias refresh_page refresh
    alias go_back back
    alias go_forward forward

    # Go to a page
    #  Usage:
    #    open_browser(:base_url => "http://www.itest2.com")
    #    ....
    #    goto_page("/purchase")  # full url => http://www.itest.com/purchase
    def goto_page(page)
			# puts "DEBUG calling goto page => #{page}" 
      @browser.goto full_url(page);
    end

    # Go to a URL directly
    #  goto_url("http://www.itest2.com/downloads")
    def goto_url(url)
      @browser.goto url
    end

    # text fields
    def enter_text_into_field_with_name(name, text)
      if is_firefox?
        wait_before_and_after { text_field(:name, name).value = text }
        sleep 0.3
      else
        wait_before_and_after { text_field(:name, name).set(text) }
      end
    end

    alias set_form_element enter_text_into_field_with_name
    alias enter_text enter_text_into_field_with_name
    alias set_hidden_field set_form_element

    #links
    def click_link_with_id(link_id, opts = {})
      if opts && opts[:index]
        wait_before_and_after { link(:id => link_id, :index => opts[:index]).click }
      else
        wait_before_and_after { link(:id, link_id).click }
      end 
    end

    def click_link_with_text(text, opts = {})
      if opts && opts[:index]
        wait_before_and_after { link(:text => text, :index => opts[:index]).click }
      else
        wait_before_and_after { link(:text, text).click }          
      end 
    end
    alias click_link click_link_with_text

    
    # Click a button with give HTML id
    # Usage:
    #   click_button_with_id("btn_sumbit")
    def click_button_with_id(id, opts = {})
      if opts && opts[:index]
          wait_before_and_after { button(:id => id,  :index => opts[:index]).click  }
      else
          wait_before_and_after { button(:id, id).click }
      end
    end

    # Click a button with give name
    # Usage:
    #   click_button_with_name("confirm")
    def click_button_with_name(name, opts={})
      if opts && opts[:index]
        wait_before_and_after { button(:name => name, :index => opts[:index]).click }
      else
        wait_before_and_after { button(:name, name).click }
      end
    end

    # Click a button with caption
    # Usage:
    #   click_button_with_caption("Confirm payment")
    def click_button_with_caption(caption, opts={})
        if opts && opts[:index]
          wait_before_and_after { button(:caption => caption, :index => opts[:index]).click }
        else
          wait_before_and_after { button(:caption, caption).click }
        end
    end
    alias click_button click_button_with_caption
    alias click_button_with_text click_button_with_caption

    # Click a button with value
    # Usage:
    #   click_button_with_value("Confirm payment")
    def click_button_with_value(value, opts={})
        if opts && opts[:index]
          wait_before_and_after { button(:value => value, :index => opts[:index]).click }
        else
          wait_before_and_after { button(:value, value).click }
        end
    end

    # Select a dropdown list by name
    # Usage:
    #   select_option("country", "Australia")
    def select_option(selectName, option)
      select_list(:name, selectName).select(option)
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
        arys.each {|cbx_value|
					if Watir::VERSION =~ /^1/ then		
          	checkbox(:name, checkBoxName, cbx_value).set						
					else
          	checkbox(:name => checkBoxName, :value => cbx_value).set
					end
        }
      else
        checkbox(:name, checkBoxName).set
      end
    end

    # Check a checkbox
    # Usage:
    #   uncheck_checkbox("agree")
    #   uncheck_checkbox("agree", "false")
    def uncheck_checkbox(checkBoxName, values = nil)
      if values
        values.class == Array ? arys = values : arys = [values]
        arys.each {|cbx_value|
					if Watir::VERSION =~ /^1/ then	
          	checkbox(:name, checkBoxName, cbx_value).clear
					else
          	checkbox(:name => checkBoxName, :value => cbx_value).clear
					end
        }
      else
        checkbox(:name, checkBoxName).clear
      end
    end


    # Click a radio button
    #  Usage:
    #    click_radio_option("country", "Australia")
    def click_radio_option(radio_group, radio_option)
			if Watir::VERSION =~ /^1/ then
      	radio(:name, radio_group, radio_option).set				
			else
      	radio(:name => radio_group, :value => radio_option).set
			end
    end
    alias click_radio_button click_radio_option

    # Clear a radio button
    #  Usage:
    #    click_radio_option("country", "Australia")
    def clear_radio_option(radio_group, radio_option)
			if Watir::VERSION =~ /^2/ then
        radio(:name => radio_group, :value => radio_option).clear				
			else
        radio(:name, radio_group, radio_option).clear
			end
    end
    alias clear_radio_button clear_radio_option

    # Deprecated: using Watir style directly instead
    def element_by_id(elem_id)
      if is_firefox?
        # elem = @browser.document.getElementById(elem_id)
        # elem = div(:id, elem_id) || label(:id, elem_id)  || button(:id, elem_id) || 
				# span(:id, elem_id) || hidden(:id, elem_id) || link(:id, elem_id) || radio(:id, elem_id)
				elem = browser.element_by_xpath("//*[@id='#{elem_id}']")
      else
        elem = @browser.document.getElementById(elem_id)
      end
    end

    def element_value(elementId)
      elem = element_by_id(elementId)
      elem ? elem.invoke('innerText') : nil
    end

    def element_source(elementId)
      elem = element_by_id(elementId)
      assert_not_nil(elem, "HTML element: #{elementId} not exists")
      elem.innerHTML
    end

    def select_file_for_upload(file_field, file_path)
      normalized_file_path = RUBY_PLATFORM.downcase.include?("mingw") ? file_path.gsub("/", "\\") : file_path
      file_field(:name, file_field).set(normalized_file_path)
    end
		
		# Watir 1.9
		def javascript_dialog
			@browser.javascript_dialog
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
      return WebBrowser.new_from_existing(Watir::IE.attach(how, what), site_context)
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
      stream.nil? ?  puts(page_source) : stream.puts(page_source)
    end

    # A Better Popup Handler using the latest Watir version. Posted by Mark_cain@rl.gov
    #
    # http://wiki.openqa.org/display/WTR/FAQ#FAQ-HowdoIattachtoapopupwindow%3F
    #
    def start_clicker( button, waitTime= 9, user_input=nil)
      # get a handle if one exists
      hwnd = @browser.enabled_popup(waitTime)
      if (hwnd)  # yes there is a popup
        w = WinClicker.new
        if ( user_input )
          w.setTextValueForFileNameField( hwnd, "#{user_input}" )
        end
        # I put this in to see the text being input it is not necessary to work
        sleep 3
        # "OK" or whatever the name on the button is
        w.clickWindowsButton_hwnd( hwnd, "#{button}" )
        #
        # this is just cleanup
        w = nil
      end
    end

    # return underlying browser
    def ie
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

#***********************************************************
#* Copyright (c) 2006, Zhimin Zhan.
#* Distributed open-source, see full license in MIT-LICENSE
#***********************************************************

begin
  require 'watir'
  require 'watir/contrib/enabled_popup'
  require 'watir/close_all'
  $watir_loaded = true
rescue LoadError => e
  $watir_loaded = false
end

begin
  require "firewatir";
  $firewatir_loaded = true
rescue LoadError => e
  $firewatir_loaded = false
end

raise "You have must at least Watir or Firewatir installed" unless $watir_loaded || $firewatir_loaded

# Patch: fix typo in Watir 1.5.3
module Watir
  class IE
    def self.close_all_but(except=nil)
      Watir::IE.each do |ie|
        ie.close_modal
        ie.close unless except and except.hwnd == ie.hwnd
      end
      sleep 1.0 # replace with polling for window count to be zero?
    end
  end
end  

module RWebUnit

  ##
  #  Wrapping WATIR and provide *assertions*
  #
  class WebTester

    attr_accessor :test_context

    def initialize(base_url = nil, options = {})
      default_options = {:speed => "fast",
        :visible => true,
        :highlight_colour => 'yellow',
      :close_others => true}
      options = default_options.merge options
      @test_context = TestContext.new base_url if base_url

      if (options[:firefox] &&  $firewatir_loaded) || ($firewatir_loaded and !$watir_loaded)
        @@browser = FireWatir::Firefox.start(base_url)
      elsif $watir_loaded
        @@browser = Watir::IE.new
        options[:speed] == 'slow' ? @@browser.set_slow_speed : @@browser.set_fast_speed

        @@browser.activeObjectHighLightColor = options[:highlight_colour]
        @@browser.visible = options[:visible]
        @@browser.close_others if options[:close_others]
      else
        raise "rWebUnit initialiazation error, most likely Watir or Firewatir not present"
      end

      if ENV['ITEST_TYPING_SPEED'] then
        @@browser.set_slow_speed if ENV['ITEST_TYPING_SPEED'] == 'slow'
        @@browser.set_fast_speed if ENV['ITEST_TYPING_SPEED'] == 'fast'
      end

    end

    ##
    #  Delegate to Watir
    #
    def area(*args)
      @@browser.area(*args)
    end
    def button(*args)
      @@browser.button(*args);
    end
    def cell(*args)
      @@browser.cell(*args);
    end
    alias td cell
    def checkbox(*args)
      @@browser.checkbox(*args);
    end
    alias check_box checkbox  # seems watir doc is wrong, checkbox not check_box
    def div(*args)
      @@browser.div(*args);
    end
    def form(*args)
      @@browser.form(*args);
    end
    def frame(*args)
      @@browser.frame(*args);
    end
    def h1(*args)
      @@browser.h1(*args);
    end
    def h2(*args)
      @@browser.h2(*args);
    end
    def h3(*args)
      @@browser.h3(*args);
    end
    def h4(*args)
      @@browser.h4(*args);
    end
    def h5(*args)
      @@browser.h5(*args);
    end
    def h6(*args)
      @@browser.h6(*args);
    end
    def hidden(*args)
      @@browser.hidden(*args);
    end
    def image(*args)
      @@browser.image(*args);
    end
    def li(*args)
      @@browser.li(*args);
    end
    def link(*args)
      @@browser.link(*args);
    end
    def map(*args)
      @@browser.map(*args);
    end
    def pre(*args)
      @@browser.pre(*args);
    end
    def radio(*args)
      @@browser.radio(*args);
    end
    def row(*args)
      @@browser.row(*args);
    end
    alias tr row
    def select_list(*args)
      @@browser.select_list(*args);
    end

    def span(*args)
      @@browser.span(*args);
    end

    def table(*args)
      @@browser.table(*args);
    end
    def text_field(*args)
      @@browser.text_field(*args);
    end

    def paragraph(*args)
      @@browser.paragraph(*args);
    end
    def file_field(*args)
      @@browser.file_field(*args);
    end
    def label(*args)
      @@browser.label(*args);
    end

    def contains_text(text)
      @@browser.contains_text(text);
    end

    def page_source
      @@browser.html()
      #@@browser.document.body
    end
    alias html_body page_source

    def page_title
      if is_firefox?
        @@browser.title
      else
        @@browser.document.title
      end
    end

    def images
      @@browser.images
    end

    def links
      @@browser.links;
    end
    def buttons
      @@browser.buttons;
    end
    def select_lists
      @@browser.select_lists;
    end
    def checkboxes
      @@browser.checkboxes;
    end
    def radios
      @@browser.radios;
    end
    def text_fields
      @@browser.text_fields;
    end

    # current url
    def url
      @@browser.url
    end

    def base_url=(new_base_url)
      if @test_context
        @test_conext.base_url = new_base_url
        return
      end
      @test_context = TestContext.new base_url
    end

    def is_firefox?
      begin
        @@browser.class == FireWatir::Firefox
      rescue => e
        return false
      end
    end

    # Close the browser window.  Useful for automated test suites to reduce
    # test interaction.
    def close_browser
      if is_firefox? then
        puts "[debug] about to close firefox"
        @@browser.close
      else
        @@browser.getIE.quit
      end
      sleep 2
    end

    def self.close_all_browsers
      if is_firefox? then
        @@browser.close_all
      else
        Watir::IE.close_all
      end
    end

    def full_url(relative_url)
      if @test_context && @test_context.base_url
        @test_context.base_url + relative_url
      else
        relative_url
      end
    end

    def begin_at(relative_url)
      @@browser.goto full_url(relative_url)
    end

    def browser_opened?
      begin
        @@browser != nil
      rescue => e
        return false
      end
    end

    # Some browsers (i.e. IE) need to be waited on before more actions can be
    # performed.  Most action methods in Watir::Simple already call this before
    # and after.
    def wait_for_browser
      @@browser.waitForIE unless is_firefox?
    end


    # A convenience method to wait at both ends of an operation for the browser
    # to catch up.
    def wait_before_and_after
      wait_for_browser
      yield
      wait_for_browser
    end


    def go_back;
      @@browser.back;
    end
    def go_forward;
      @@browser.forward;
    end
    def goto_page(page)
      @@browser.goto full_url(page);
    end
    def refresh;
      @@browser.refresh;
    end

    def focus;
      @@browser.focus;
    end
    def close_others;
      @@browser.close_others;
    end

    # text fields
    def enter_text_into_field_with_name(name, text)
      if is_firefox?
        wait_before_and_after { text_field(:name, name).value = text }
        sleep 0.5
      else
        wait_before_and_after { text_field(:name, name).set(text) }
      end
    end
    alias set_form_element enter_text_into_field_with_name
    alias enter_text enter_text_into_field_with_name

    #links
    def click_link_with_id(link_id)
      wait_before_and_after { link(:id, link_id).click }
    end

    def click_link_with_text(text)
      wait_before_and_after { link(:text, text).click }
    end

    ##
    # buttons

    def click_button_with_id(id)
      wait_before_and_after { button(:id, id).click }
    end

    def click_button_with_name(name)
      wait_before_and_after { button(:name, name).click }
    end

    def click_button_with_caption(caption)
      wait_before_and_after { button(:caption, caption).click }
    end

    def click_button_with_value(value)
      wait_before_and_after { button(:value, value).click }
    end

    def select_option(selectName, option)
      #      @@browser.selectBox(:name, selectName).select(option)
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

    # checkbox
    def check_checkbox(checkBoxName, values=nil)
      if values
        values.class == Array ? arys = values : arys = [values]
        arys.each {|cbx_value|
          checkbox(:name, checkBoxName, cbx_value).set
        }
      else
        checkbox(:name, checkBoxName).set
      end
    end

    def uncheck_checkbox(checkBoxName, values = nil)
      if values
        values.class == Array ? arys = values : arys = [values]
        arys.each {|cbx_value|
          checkbox(:name, checkBoxName, cbx_value).clear
        }
      else
        checkbox(:name, checkBoxName).clear
      end
    end


    # the method is protected in JWebUnit
    def click_radio_option(radio_group, radio_option)
      radio(:name, radio_group, radio_option).set
    end

    def clear_radio_option(radio_group, radio_option)
      radio(:name, radio_group, radio_option).clear
    end

    def element_by_id(elem_id)
      if is_firefox?
        elem =  label(:id, elem_id)  || button(:id, elem_id) || span(:id, elem_id) || hidden(:id, elem_id) || link(:id, elem_id) || radio(:id, elem_id)
      else
        elem = @@browser.document.getElementById(elem_id)
      end
    end

    def element_value(elementId)
      if is_firefox? then
        elem = element_by_id(elementId)
        elem ? elem.invoke('innerText') : nil
      else
        elem = element_by_id(elementId)
        elem ? elem.invoke('innerText') : nil
      end
    end

    def element_source(elementId)
      elem = element_by_id(elementId)
      assert_not_nil(elem, "HTML element: #{elementId} not exists")
      elem.innerHTML
    end

    def select_file_for_upload(file_field, file_path)
      file_field(:name, file_field).set(file_path)
    end

    def start_window(url = nil)
      @@browser.start_window(url);
    end

    def self.attach_browser(how, what)
      if @@browser && @@browser.class == Watir::IE
        Watir::IE.attach(how, what)
      else
        raise "not implemented yet"
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
      if stream.nil?
        puts page_source # std out
      else
        stream.puts page_source
      end
    end

    # A Better Popup Handler using the latest Watir version. Posted by Mark_cain@rl.gov
    #
    # http://wiki.openqa.org/display/WTR/FAQ#FAQ-HowdoIattachtoapopupwindow%3F
    #
    def start_clicker( button, waitTime= 9, user_input=nil)
      # get a handle if one exists
      hwnd = @@browser.enabled_popup(waitTime)
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
      raise "can't call this as it is configured to use Firefox" if is_firefox?
      @@browser
    end

    def firefox
      raise "can't call this as it is configured to use IE" unless is_firefox?
      @@browser
    end

    def save_page(file_name = nil)
      file_name ||= Time.now.strftime("%Y%m%d%H%M%S") + ".html"
      puts "about to save page: #{File.expand_path(file_name)}"
      File.open(file_name, "w").puts page_source
    end

  end

end

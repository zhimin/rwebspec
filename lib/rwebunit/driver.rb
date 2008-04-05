# The Mixin is normally included in the spec/tests and pages, provide
# convenient methods to drive the browser.
#
# Instead of
#    browser.click_button("submit")
# You can just use
#    click_button("submit")
#

module RWebUnit
  module Driver

    # Verify the next page following an operation.
    #
    # Typical usage:
    #   login_page.click_login
    #   expect_page HomePage
    def expect_page(page_clazz)
      page_clazz.new(@web_tester)
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

    def test_context
      @web_tester.test_context
    end

    def begin_at(url)
      @web_tester.begin_at(url)
    end

    def ie;
      @web_tester.ie;
    end

    def close_browser
      @web_tester.close_browser unless ENV['ITEST_LEAVE_BROWSER_OPEN_AFTER_RUN'] == "true"
    end
    alias close_ie close_browser

    # browser navigation
    def go_back;
      @web_tester.go_back;
    end
    def go_forward;
      @web_tester.go_forward;
    end

    def goto_page(page)
      operation_delay
      @web_tester.goto_page(page);
    end
    def refresh;
      @web_tester.refresh;
    end
    alias refresh_page refresh

    def attach_browser(how, what)
      WebTester.attach_browser(how, what)
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
    def area(*args)
      @web_tester.area(*args);
    end
    def button(*args)
      @web_tester.button(*args);
    end
    def cell(*args)
      @web_tester.cell(*args);
    end
    alias td cell
    
    def checkbox(*args)
      @web_tester.checkbox(*args);
    end
    alias check_box checkbox  # seems watir doc is wrong, checkbox not check_box
    
    def div(*args)
      @web_tester.div(*args);
    end
    def form(*args)
      @web_tester.form(*args);
    end
    def frame(*args)
      @web_tester.frame(*args);
    end
    def h1(*args)
      @web_tester.h1(*args);
    end
    def h2(*args)
      @web_tester.h2(*args);
    end
    def h3(*args)
      @web_tester.h3(*args);
    end
    def h4(*args)
      @web_tester.h4(*args);
    end
    def h5(*args)
      @web_tester.h5(*args);
    end
    def h6(*args)
      @web_tester.h6(*args);
    end
    def hidden(*args)
      @web_tester.hidden(*args);
    end
    def image(*args)
      @web_tester.image(*args);
    end
    def li(*args)
      @web_tester.li(*args);
    end
    def link(*args)
      @web_tester.link(*args);
    end
    def map(*args)
      @web_tester.map(*args);
    end
    def pre(*args)
      @web_tester.pre(*args);
    end
    def row(*args)
      @web_tester.row(*args);
    end
    alias tr row
    
    def radio(*args)
      @web_tester.radio(*args);
    end
    def select_list(*args)
      @web_tester.select_list(*args);
    end
    def span(*args)
      @web_tester.span(*args);
    end
    def table(*args)
      @web_tester.table(*args);
    end
    def text_field(*args)
      @web_tester.text_field(*args);
    end

    def paragraph(*args)
      @web_tester.paragraph(*args);
    end
    def file_field(*args)
      @web_tester.file_field(*args);
    end
    def label(*args)
      @web_tester.label(*args);
    end

    def contains_text(text)
      @web_tester.contains_text(text);
    end


    def images;
      @web_tester.images;
    end
    def links;
      @web_tester.links;
    end
    def buttons;
      @web_tester.buttons;
    end
    def select_lists;
      @web_tester.select_lists;
    end
    def checkboxes;
      @web_tester.checkboxes;
    end
    def radios;
      @web_tester.radios;
    end
    def text_fields;
      @web_tester.text_fields;
    end


    # enter text into a text field
    def enter_text(elementName, elementValue)
      operation_delay
      @web_tester.set_form_element(elementName, elementValue)
    end
    alias set_form_element enter_text


    #links
    def click_link_with_text(link_text)
      operation_delay
      @web_tester.click_link_with_text(link_text)
    end
    alias click_link click_link_with_text

    def click_link_with_id(link_id)
      operation_delay
      @web_tester.click_link_with_id(link_id)
    end

    ##
    # buttons

    # submit the form using the first (index) submit button
    def submit()
      operation_delay
      @web_tester.submit()
    end

    # click a form submit button with specified button id
    def submit(button_id)
      operation_delay
      @web_tester.submit(button_id)
    end

    def click_button_with_id(button_id)
      operation_delay
      @web_tester.click_button_with_id(button_id)
    end

    def click_button_with_caption(caption)
      operation_delay
      @web_tester.click_button_with_caption(caption)
    end
    alias click_button_with_text click_button_with_caption
    alias click_button click_button_with_caption

    def click_button_with_image_src_contains(image_filename)
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

    def click_button_with_value(value)
      operation_delay
      @web_tester.click_button_with_value(value)
    end

    # Radios
    def click_radio_option(name, value)
      operation_delay
      @web_tester.click_radio_option(name, value)
    end
    alias click_radio_button click_radio_option

    def clear_radio_option(name, value)
      operation_delay
      @web_tester.clear_radio_option(name, value)
    end
    alias clear_radio_button clear_radio_option

    # Filefield
    def select_file_for_upload(file_field, file_path)
      operation_delay
      @web_tester.select_file_for_upload(file_field, file_path)
    end

    # Check one or more checkboxes with same name, can accept a string or an array of string as values checkbox, pass array as values will try to set mulitple checkboxes.
    #
    # page.check_checkbox('bad_ones', 'Chicken Little')
    # page.check_checkbox('good_ones', ['Cars', 'Toy Story'])
    def check_checkbox(name, value=nil)
      operation_delay
      @web_tester.check_checkbox(name, value)
    end

    # Uncheck one or more checkboxes with same name
    def uncheck_checkbox(name, value=nil)
      operation_delay
      @web_tester.uncheck_checkbox(name, value)
    end

    # combo box
    def select_option(selectName, option)
      operation_delay
      @web_tester.select_option(selectName, option)
    end

    def new_popup_window(options)
      @web_tester.new_popup_window(options)
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
      check_interval = 2 if check_interval < 1 or check_interval > seconds
      while count < (seconds / check_interval) do
        search_indicator = @web_tester.element_by_id(element_id)
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
      until @web_tester.element_by_id(element_id) do
        sleep(interval)
        if (Time.now - start_time) > timeout
          raise RuntimeError, "failed to find element: #{element_id} for max #{timeout}"
        end
      end
    end

    def element_text(elem_id)
      @web_tester.element_value(elem_id)
    end

    # fail the test if user can perform the operation
    def shall_not_allow
      operation_performed_ok = false
      begin
        yield
        operation_performed_ok  = true
      rescue
      end

      raise "Operation shall not be allowed" if operation_performed_ok
    end
    alias do_not_allow shall_not_allow

    # ---
    # For debugging
    # ---
    def dump_response(stream = nil)
      @web_tester.dump_response(stream)
    end

    def click_popup_window(button, waitTime= 9, user_input=nil )
      @web_tester.start_clicker(button, waitTime, user_input)
    end

    def operation_delay
      begin
        if ENV['ITEST_OPERATION_DELAY']  && ENV['ITEST_OPERATION_DELAY'].to_i > 0 && ENV['ITEST_OPERATION_DELAY'].to_f < 30000  then # max 30 seconds
          sleep(ENV['ITEST_OPERATION_DELAY'].to_f / 1000)
        end
      rescue => e
        # ignore
      end
    end

  end
end

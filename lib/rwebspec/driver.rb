# convenient methods to drive the browser.
# convenient methods to drive the browser.
#
# Instead of
#    browser.click_button("submit")
# You can just use
#    click_button("submit")
#
require File.join(File.dirname(__FILE__), 'testwise_plugin')
require File.join(File.dirname(__FILE__), 'popup')
require File.join(File.dirname(__FILE__), 'matchers', "contains_text.rb")

require 'timeout'
require 'uri'

# require 'watir/screen_capture' if RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw")

module RWebSpec
  module Driver
    include RWebSpec::TestWisePlugin
    include RWebSpec::Popup
    # include Watir::ScreenCapture if RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw")

    @@default_polling_interval = 1 # second
    @@default_timeout = 30 # seconds

    # open a browser, and set base_url via hash, but does not acually
    #
    # example:
    #   open_browser :base_url => http://localhost:8080
    #
    # There are 3 ways to set base url
    #   1. pass as first argument
    #   2. If running using TestWise, used as confiured
    #   3. Use default value set
    def open_browser(base_url = nil, options = {})

      begin
        support_unicode
      rescue => e
        puts "Unicode may not work in IE, #{e}"
      end

      base_url ||= $ITEST2_PROJECT_BASE_URL
      base_url ||= $BASE_URL
      raise "base_url must be set" if base_url.nil?

      default_options = {:speed => "fast",
                         :visible => true,
                         :highlight_colour => 'yellow',
                         :close_others => true,
                         :start_new => false, # start a new browser always
                         :go => true}

      options = default_options.merge options
      options[:firefox] = true if "Firefox" == $ITEST2_BROWSER || "Firefox" == $BROWSER
      ($ITEST2_HIDE_BROWSER) ? $HIDE_IE = true : $HIDE_IE = false

      if base_url =~ /^file:/
        uri_base = base_url
      else
        uri = URI.parse(base_url)
        uri_base = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      end

      if options[:start_new] || $celerity_loaded
        @web_browser = WebBrowser.new(uri_base, nil, options)
      else
        @web_browser = WebBrowser.reuse(uri_base, options) # Reuse existing browser
      end

      if base_url =~ /^file:/
        goto_url(base_url) # for files, no base url
      else
        (uri.path.length == 0) ? begin_at("/") : begin_at(uri.path) if options[:go]
      end

      return @web_browser
    end

    alias open_browser_with open_browser

    # return the underlying RWebSpec::Browser object
    def browser
      @web_browser
    end


    # Close the current browser window (started by the script). If no browser started, then close
    # all browser windows.
    #
    def close_browser
      if @web_browser
        # Old TestWise version
        # @web_browser.close_browser unless $ITEST2_LEAVE_BROWSER_OPEN_AFTER_RUN
        @web_browser.close_browser
      else
				close_all_browsers
      end
    end
    alias close_ie close_browser


    # Close all opening browser windows
    #
    def close_all_browsers
			if @web_browser
	      if is_firefox?
	        FireWatir::Firefox.close_all
	      else
	        Watir::IE.close_all
	      end
			else
				browser_type = $ITEST2_BROWSER ? $ITEST2_BROWSER.downcase.to_sym : :ie	
	      WebBrowser.close_all_browsers(browser_type)				
			end
    end

    # Verify the next page following an operation.
    #
    # Typical usage:
    #   login_page.click_login
    #   expect_page HomePage
    def expect_page(page_clazz, argument = nil)
      if argument
        @web_browser.expect_page(page_clazz, argument)
      else
        @web_browser.expect_page(page_clazz)
      end
    end

    def context
      @web_browser.context
    end

    # Starting browser with a URL
    #
    # Example:
    #    begin_at("http://www.itest2.com")
    def begin_at(url)
      dump_caller_stack
      @web_browser.begin_at(url)
    end

    # Return the Watir::IE instance
    #
    def ie
      @web_browser.ie
    end

    # Return the FireWatir::Firefox instance
    #
    def firefox
      @web_browser.firefox
    end

    def is_firefox?
      @web_browser.is_firefox? if @web_browser
    end

    def is_celerity? 
      RUBY_PLATFORM =~ /java/ && @web_browser
    end

    # Go to another page on the testing site.
    #
    #  open_browser("http://www.itest2.com")
    #  goto_page("/demo")  # visit page http://www.itest2.com/demo
    #
    def goto_page(page)
      perform_operation {
        @web_browser.goto_page(page) if @web_browser
      }
    end
    alias visit goto_page

    
    # Go to another web site, normally different site being tested on
    #
    #  open_browser("http://www.itest2.com")
    #  goto_url("http://myorganized.info")
    def goto_url(url)
      @web_browser.goto_url url
    end

    # Go to specific url in background (i.e not via browwser, different from goto_url)
    # This won't share the session with what's currenlty in browser, proxy setting
    #
    # One use example: resetting database
    #   background_visit("/reset")
    #
    def background_visit(url, opts = {})
      require 'httpclient'
      begin
        client = HTTPClient.new
        if url && url =~ /^http/
            http_response = client.get(url).body
        else
            base_url = $ITEST2_PROJECT_BASE_URL || $BASE_URL
            http_response = client.get("#{base_url}#{url}").body
        end
				
				http_response = http_response.content if http_response.respond_to?("content")
      rescue => e
        raise e
      end
    end
    
    # Attach to existing browser window
    #
    #  attach_browser(:title, "Page" )
    #  attach_browser(:url, "http://wwww..." )
    def attach_browser(how, what, options = {})
      options.merge!(:browser => is_firefox? ? "Firefox" : "IE") unless options[:browser]
      begin
        options.merge!(:base_url => browser.context.base_url)
      rescue => e
        puts "failed to set base_url, ignore : #{e}"
      end
      WebBrowser.attach_browser(how, what, options)
    end

    # Reuse current an opened browser window instead of opening a new one
    #	example:
    #     use_current_browser(:title, /.*/) # use what ever browser window
    #     use_current_browser(:title, "TestWise") # use browser window with title "TestWise"
    def use_current_browser(how = :title, what = /.*/)
      @web_browser = WebBrowser.attach_browser(how, what)
    end

    ##
    #  Delegate to WebTester
    #
    # Note:
    #   label(:id, "abc") # OK
    #   label(:id, :abc)  # Error
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
      define_method method do |* args|
        perform_operation { @web_browser.send(method, * args) if @web_browser }
      end
    end
    alias td cell
    alias check_box checkbox # seems watir doc is wrong, checkbox not check_box
    alias tr row
    alias a link
    alias img image


    [:back, :forward, :refresh].each do |method|
      define_method(method) do
        perform_operation { @web_browser.send(method) if @web_browser }
      end
    end
    alias refresh_page refresh
    alias go_back back
    alias go_forward forward

    [:images, :links, :buttons, :select_lists, :checkboxes, :radios, :text_fields, :divs, :dls, :dds, :dts, :ems, :lis, :maps, :spans, :strongs, :ps, :pres, :labels, :cells, :rows].each do |method|
      define_method method do
        perform_operation { @web_browser.send(method) if @web_browser }
      end
    end
		alias as links
		alias trs rows
		alias tds cells
		alias imgs images

	
    # Check one or more checkboxes with same name, can accept a string or an array of string as values checkbox, pass array as values will try to set mulitple checkboxes.
    #
    # page.check_checkbox('bad_ones', 'Chicken Little')
    # page.check_checkbox('good_ones', ['Cars', 'Toy Story'])
    #
    [:set_form_element, :click_link_with_text, :click_link_with_id, :submit, :click_button_with_id, :click_button_with_name, :click_button_with_caption, :click_button_with_value, :click_radio_option, :clear_radio_option, :check_checkbox, :uncheck_checkbox, :select_option].each do |method|
      define_method method do |* args|
        perform_operation { @web_browser.send(method, * args) if @web_browser }
      end
    end

    alias enter_text set_form_element
    alias set_hidden_field set_form_element
    alias click_link click_link_with_text
    alias click_button_with_text click_button_with_caption
    alias click_button click_button_with_caption
    alias click_radio_button click_radio_option
    alias clear_radio_button clear_radio_option

    # for text field can be easier to be identified by attribute "id" instead of "name", not recommended though
    def enter_text_with_id(textfield_id, value)
      perform_operation { text_field(:id, textfield_id).set(value) }
    end

    def perform_operation(& block)
      begin
        dump_caller_stack
        operation_delay
        yield
      rescue RuntimeError => re
        raise re
        #      ensure
        #        puts "[DEBUG] ensure #{perform_ok}" unless perform_ok
      end
    end

    def contains_text(text)
      @web_browser.contains_text(text)
    end

    # In pages, can't use include, text.should include("abc") won't work
    # Instead,
    #   text.should contains("abc"
    def contains(str)
      ContainsText.new(str)
    end

    alias contain contains

    # Click image buttion with image source name
    #
    # For an image submit button <input name="submit" type="image" src="/images/search_button.gif">
    #  click_button_with_image("search_button.gif")
    def click_button_with_image_src_contains(image_filename)
      perform_operation {
        found = nil
        raise "no buttons in this page" if buttons.length <= 0
        buttons.each { |btn|
          if btn && btn.src && btn.src.include?(image_filename) then
            found = btn
            break
          end
        }
        raise "not image button with src: #{image_filename} found" if found.nil?
        found.click
      }
    end

    alias click_button_with_image click_button_with_image_src_contains

    def new_popup_window(options)
      @web_browser.new_popup_window(options)
    end


    # Warning: this does not work well with Firefox yet.
    def element_text(elem_id)
      @web_browser.element_value(elem_id)
    end

    # Identify DOM element by ID
    # Warning: it is only supported on IE
    def element_by_id(elem_id)
      @web_browser.element_by_id(elem_id)
    end

    # ---
    # For debugging
    # ---
    def dump_response(stream = nil)
      @web_browser.dump_response(stream)
    end

    def default_dump_dir
      if $ITEST2_RUNNING_SPEC_ID && $ITEST2_WORKING_DIR

        $ITEST2_DUMP_DIR = File.join($ITEST2_WORKING_DIR, "dump")
        FileUtils.mkdir($ITEST2_DUMP_DIR) unless File.exists?($ITEST2_DUMP_DIR)

        spec_run_id = $ITEST2_RUNNING_SPEC_ID
        spec_run_dir_name = spec_run_id.to_s.rjust(4, "0") unless spec_run_id == "unknown"
        to_dir = File.join($ITEST2_DUMP_DIR, spec_run_dir_name)
      else
        to_dir = ENV['TEMP_DIR'] || (is_windows? ? "C:\\temp" : "/tmp")
      end
    end

    # For current page souce to a file in specified folder for inspection
    #
    #   save_current_page(:dir => "C:\\mysite", filename => "abc", :replacement => true)
    def save_current_page(options = {})
      default_options = {:replacement => true}
      options = default_options.merge(options)
      to_dir = options[:dir] || default_dump_dir

      if options[:filename]
        file_name = options[:filename]
      else
        file_name = Time.now.strftime("%m%d%H%M%S") + ".html"
      end

      Dir.mkdir(to_dir) unless File.exists?(to_dir)
      file = File.join(to_dir, file_name)

      content = page_source
      base_url = @web_browser.context.base_url
      current_url = @web_browser.url
      current_url =~ /(.*\/).*$/
      current_url_parent = $1
      if options[:replacement] && base_url =~ /^http:/
        File.new(file, "w").puts absolutize_page_nokogiri(content, base_url, current_url_parent)
      else
        File.new(file, "w").puts content
      end

    end


    # <link rel="stylesheet" type="text/css" href="/stylesheets/default.css" />
    # '<script type="text/javascript" src="http://www.jeroenwijering.com/embed/swfobject.js"></script>'
    # <script type="text/javascript" src="/javascripts/prototype.js"></script>
    # <script type="text/javascript" src="/javascripts/scriptaculous.js?load=effects,builder"></script>
    # <script type="text/javascript" src="/javascripts/extensions/gallery/lightbox.js"></script>
    # <link href="/stylesheets/extensions/gallery/lightbox.css" rel="stylesheet" type="text/css" />
    # <img src="images/mission_48.png" />
    def absolutize_page(content, base_url, current_url_parent)
      modified_content = ""
      content.each_line do |line|
        if line =~ /<script\s+.*src=["'']?(.*)["'].*/i then
          script_src = $1
          substitute_relative_path_in_src_line(line, script_src, base_url, current_url_parent)
        elsif line =~ /<link\s+.*href=["'']?(.*)["'].*/i then
          link_href = $1
          substitute_relative_path_in_src_line(line, link_href, base_url, current_url_parent)
        elsif line =~ /<img\s+.*src=["'']?(.*)["'].*/i then
          img_src = $1
          substitute_relative_path_in_src_line(line, img_src, base_url, current_url_parent)
        end

        modified_content += line
      end
      return modified_content
    end

    # absolutize_page referencs using hpricot
    #   
    def absolutize_page_hpricot(content, base_url, parent_url)
      return absolutize_page(content, base_url, parent_url) if RUBY_PLATFORM == 'java'
      begin
        require 'hpricot'
        doc = Hpricot(content)
        base_url.slice!(-1) if ends_with?(base_url, "/")
        (doc/'link').each { |e| e['href'] = absolutify_url(e['href'], base_url, parent_url) || "" }
        (doc/'img').each { |e| e['src'] = absolutify_url(e['src'], base_url, parent_url) || "" }
        (doc/'script').each { |e| e['src'] = absolutify_url(e['src'], base_url, parent_url) || "" }
        return doc.to_html
      rescue => e
        absolutize_page(content, base_url, parent_url)
      end
    end  

  	def absolutize_page_nokogiri(content, base_url, parent_url)
      return absolutize_page(content, base_url, parent_url) if RUBY_PLATFORM == 'java'
      begin
        require 'nokogiri'
        doc = Nokogiri::HTML(content)
        base_url.slice!(-1) if ends_with?(base_url, "/")
        (doc/'link').each { |e| e['href'] = absolutify_url(e['href'], base_url, parent_url) || "" }
        (doc/'img').each { |e| e['src'] = absolutify_url(e['src'], base_url, parent_url) || "" }
        (doc/'script').each { |e| e['src'] = absolutify_url(e['src'], base_url, parent_url) || "" }
        return doc.to_html
      rescue => e
        absolutize_page(content, base_url, parent_url)
      end
    end

    ## 
    # change 
    #   <script type="text/javascript" src="/javascripts/prototype.js"></script>
    # to
    #   <script type="text/javascript" src="http://itest2.com/javascripts/prototype.js"></script>
    def absolutify_url(src, base_url, parent_url)
      if src.nil? || src.empty? || src == "//:" || src =~ /\s*http:\/\//i
        return src
      end

      return "#{base_url}#{src}" if src =~ /^\s*\//
      return "#{parent_url}#{src}" if parent_url
      return src
    end

    # substut
    def substitute_relative_path_in_src_line(line, script_src, host_url, page_parent_url)
      unless script_src =~ /^["']?http:/
        host_url.slice!(-1) if ends_with?(host_url, "/")
        if script_src =~ /^\s*\// # absolute_path
          line.gsub!(script_src, "#{host_url}#{script_src}")
        else #relative_path
          line.gsub!(script_src, "#{page_parent_url}#{script_src}")
        end
      end
    end

    def ends_with?(str, suffix)
      suffix = suffix.to_s
      str[-suffix.length, suffix.length] == suffix
    end

    # current web page title
    def page_title
      @web_browser.page_title
    end

    # current page source (in HTML)
    def page_source
      @web_browser.page_source
    end

    # return plain text view of page
    def page_text
      @web_browser.text
    end

    # return the text of specific (identified by attribute "id") label tag
    # For page containing
    #     <label id="preferred_ide">TestWise</label>
    # label_with_id("preferred_ids") # => TestWise
    # label_with_id("preferred_ids", :index => 2) # => TestWise
    def label_with_id(label_id, options = {})
      if options && options[:index] then
        label(:id => label_id.to_s, :index => options[:index]).text
      else
        label(:id, label_id.to_s).text
      end
    end

    # return the text of specific (identified by attribute "id") span tag
    # For page containing
    #     <span id="preferred_recorder">iTest2/Watir Recorder</span>
    # span_with_id("preferred_recorder") # => iTest2/Watir Recorder
    def span_with_id(span_id, options = {})
      if options && options[:index] then
        span(:id => span_id.to_s, :index => options[:index]).text
      else
        span(:id, span_id).text
      end
    end

    # return the text of specific (identified by attribute "id") ta tag
    # For page containing
    #     <td id="preferred_recorder">iTest2/Watir Recorder</span>
    # td_with_id("preferred_recorder") # => iTest2/Watir Recorder
    def cell_with_id(cell_id, options = {})
      if options && options[:index] then
        cell(:id => cell_id.to_s, :index => options[:index]).text
      else
        cell(:id, cell_id).text
      end
    end

    alias table_data_with_id cell_with_id


    def is_mac?
      RUBY_PLATFORM.downcase.include?("darwin")
    end

    def is_windows?
      RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw")
    end

    def is_linux?
      RUBY_PLATFORM.downcase.include?("linux")
    end

    # Support browser (IE) operations using unicode
    #  Example:
    #   click_button("Google 搜索")
    # Reference: http://jira.openqa.org/browse/WTR-219
    def support_utf8
      if is_windows?
        require 'win32ole'
        WIN32OLE.codepage = WIN32OLE::CP_UTF8
      end
    end

    alias support_unicode support_utf8

    #= Convenient functions
    #

    # Using Ruby block syntax to create interesting domain specific language,
    # may be appeal to someone.

    # Example:
    #  on @page do |i|
    #    i.enter_text('btn1')
    #    i.click_button('btn1')
    #  end
    def on(page, & block)
      yield page
    end

    # fail the test if user can perform the operation
    #
    # Example:
    #  shall_not_allow { 1/0 }
    def shall_not_allow(& block)
      operation_performed_ok = false
      begin
        yield
        operation_performed_ok = true
      rescue
      end
      raise "Operation shall not be allowed" if operation_performed_ok
    end

    alias do_not_allow shall_not_allow

    # Does not provide real function, other than make enhancing test syntax
    #
    # Example:
    #   allow { click_button('Register') }
    def allow(& block)
      yield
    end

    alias shall_allow allow
    alias allowing allow

    # try operation, ignore if errors occur
    #
    # Example:
    #   failsafe { click_link("Logout") }  # try logout, but it still OK if not being able to (already logout))
    def failsafe(& block)
      begin
        yield
      rescue =>e
      end
    end

    alias fail_safe failsafe


    # Execute the provided block until either (1) it returns true, or
    # (2) the timeout (in seconds) has been reached. If the timeout is reached,
    # a TimeOutException will be raised. The block will always
    # execute at least once.
    #
    # This does not handle error, if the given block raise error, the statement finish with error
    # Examples:
    #   wait_until {puts 'hello'}
    #   wait_until { div(:id, :receipt_date).exists? }
    #
    def wait_until(timeout = @@default_timeout || 30, polling_interval = @@default_polling_interval || 1, & block)
      waiter = Watir::Waiter.new(timeout, polling_interval)
      waiter.wait_until { yield }
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
    def ajax_wait_for_element(element_id, seconds, status='show', check_interval = @@default_polling_interval)
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

    #Wait the element with given id to be present in web page
    #
    # Warning: this not working in Firefox, try use wait_util or try instead
    def wait_for_element(element_id, timeout = @@default_timeout, interval = @@default_polling_interval)
      start_time = Time.now
      #TODO might not work with Firefox
      until @web_browser.element_by_id(element_id) do
        sleep(interval)
        if (Time.now - start_time) > timeout
          raise RuntimeError, "failed to find element: #{element_id} for max #{timeout}"
        end
      end
    end

=begin

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

=end

    # Try the operation up to specified times, and sleep given interval (in seconds)
    # Error will be ignored until timeout
    # Example
    #    repeat_try(3, 2) { click_button('Search' } # 3 times, 6 seconds in total
    #    repeat_try { click_button('Search' } # using default 5 tries, 2 second interval
    def repeat_try(num_tries = @@default_timeout || 30, interval = @@default_polling_interval || 1, & block)
      num_tries ||= 1
      (num_tries - 1).times do |num|
        begin
          yield
          return
        rescue => e
          # puts "debug: #{num} failed: #{e}"
          sleep interval
        end
      end

      # last try, throw error if still fails
      begin
        yield
      rescue => e
        raise e.to_s + " after trying #{num_tries} times every #{interval} seconds"
      end
      yield
    end

    # TODO: syntax

    # Try the operation up to specified timeout (in seconds), and sleep given interval (in seconds).
    # Error will be ignored until timeout
    # Example
    #    try { click_link('waiting')}
    #    try(10, 2) { click_button('Search' } # try to click the 'Search' button upto 10 seconds, try every 2 seconds
    #    try { click_button('Search' }
    def try(timeout = @@default_timeout, polling_interval = @@default_polling_interval || 1, & block)
      start_time = Time.now

      last_error = nil
      until (duration = Time.now - start_time) > timeout
        begin
          yield
          last_error = nil
					return true 
        rescue => e
          last_error = e
        end
        sleep polling_interval
      end

      raise "Timeout after #{duration.to_i} seconds with error: #{last_error}." if last_error
      raise "Timeout after #{duration.to_i} seconds."
    end

    alias try_upto try

    ##
    #  Convert :first to 1, :second to 2, and so on...
    def symbol_to_sequence(symb)
      value = {:zero => 0,
               :first => 1,
               :second => 2,
               :third => 3,
               :fourth => 4,
               :fifth => 5,
               :sixth => 6,
               :seventh => 7,
               :eighth => 8,
               :ninth => 9,
               :tenth => 10}[symb]
      return value || symb.to_i
    end

    # Clear popup windows such as 'Security Alert' or 'Security Information' popup window,
    #
    # Screenshot see http://kb2.adobe.com/cps/165/tn_16588.html
    # 
    # You can  also by pass security alerts by change IE setting, http://kb.iu.edu/data/amuj.html 
    #
    # Example
    #   clear_popup("Security Information", 5, true) # check for Security Information for 5 seconds, click Yes
    def clear_popup(popup_win_title, seconds = 10, yes = true)
      # commonly "Security Alert", "Security Information"
      if is_windows?
        sleep 1
        autoit = WIN32OLE.new('AutoItX3.Control')
        # Look for window with given title. Give up after 1 second.
        ret = autoit.WinWait(popup_win_title, '', seconds)
        #
        # If window found, send appropriate keystroke (e.g. {enter}, {Y}, {N}).
        if ret == 1 then
          puts "about to send click Yes" if debugging?
          button_id = yes ? "Button1" : "Button2" # Yes or No
          autoit.ControlClick(popup_win_title, '', button_id)
        end
        sleep(0.5)
      else
        raise "Currently supported only on Windows"
      end
    end

		# Watir 1.9 way of handling javascript dialog
		def javascript_dialog
			@web_browser.javascript_dialog
		end
		
    def select_file_for_upload(file_field_name, file_path)
      if is_windows?
        normalized_file_path = file_path.gsub("/", "\\")
        if $support_ie8 && check_ie_version && @ie_version >= 8
          # puts "IE8"
          file_field(:name, file_field).set(normalized_file_path)
          # choose_file_dialog(normalized_file_path)
        else
          file_field(:name, file_field).set(normalized_file_path)
        end
      else
        # for firefox, just call file_field, it may fail
        file_field(:name, file_field).set(normalized_file_path)
      end
    end

    def choose_file_dialog(file_path)
      Watir.autoit.WinWaitActive("Choose File to Upload", '', 10)
      Watir.autoit.ControlSetText("Choose File to Upload", "", 1148, file_path)
      Watir.autoit.ControlClick("Choose File to Upload", "", "&Open")
    end

    def check_ie_version
      if is_windows? && @ie_version.nil?
        begin
          cmd = 'reg query "HKLM\SOFTWARE\Microsoft\Internet Explorer" /v Version';
          result = `#{cmd}`
          version_line = nil
          result.each do |line|
            if (line =~ /Version\s+REG_SZ\s+([\d\.]+)/)
              version_line = $1
            end
          end

          if version_line =~ /^\s*(\d+)\./
            @ie_version = $1.to_i
          end
        rescue => e
        end
      end
    end

    # Use AutoIT3 to send password
    # title starts with "Connect to ..."
    def basic_authentication_ie(title, username, password, options = {})
      default_options = {:textctrl_username => "Edit2",
                         :textctrl_password => "Edit3",
                         :button_ok => 'Button1'
      }

      options = default_options.merge(options)

      title ||= ""      
      if title =~ /^Connect\sto/
        full_title = title
      else
        full_title = "Connect to #{title}"
      end
      require 'rformspec'
      login_win = RFormSpec::Window.new(full_title)
      login_win.send_control_text(options[:textctrl_username], username)
      login_win.send_control_text(options[:textctrl_password], password)
      login_win.click_button("OK")
    end

    # Use JSSH to pass authentication
    #  Window title "Authentication required"
    def basic_authentication_firefox(username, password, wait = 3)
      jssh_command = "
    var length = getWindows().length;
    var win;
    var found = false;
    for (var i = 0; i < length; i++) {
      win = getWindows()[i];
      if(win.document.title == \"Authentication Required\") {
        found = true;
        break;
      }
    }
    if (found) {
      var jsdocument = win.document;
      var dialog = jsdocument.getElementsByTagName(\"dialog\")[0];
      jsdocument.getElementsByTagName(\"textbox\")[0].value = \"#{username}\";
      jsdocument.getElementsByTagName(\"textbox\")[1].value = \"#{password}\";
      dialog.getButton(\"accept\").click();
    }
    \n"
      sleep(wait)
      $jssh_socket.send(jssh_command, 0)
      # read_socket()
    end

    def basic_authentication_celerity(username, password)
      @web_browser.celerity.credentials = "#{username}:#{password}"
    end

    def basic_authentication(username, password, options = {})
      if is_celerity?
        basic_authentication_celerity(username, password)
      elsif is_firefox?
        basic_authentication_firefox(username, password)
      else
        basic_authentication_ie(options[:title], username, password, options)
      end
    end

    # take_screenshot to save the current active window
    # TODO can't move mouse
    def take_screenshot_old
      if is_windows? && $ITEST2_DUMP_PAGE
        begin
          puts "[DEBUG] Capturing screenshots..."
          screenshot_image_filename =  "rwebspec_" + Time.now.strftime("%m%d%H%M%S") + ".jpg"
          the_dump_dir = default_dump_dir
          FileUtils.mkdir_p(the_dump_dir) unless File.exists?(the_dump_dir)
          screenshot_image_filepath = File.join(the_dump_dir, screenshot_image_filename)

          screenshot_image_filepath.gsub!("/", "\\") if is_windows?
          screen_capture(screenshot_image_filepath, true)

          notify_screenshot_location(screenshot_image_filepath)
        rescue
          puts "error: #{Failed to capture screen}"
        end
      end
    end



    # use win32screenshot library to save curernt active window, which shall be IE
    #
    def take_screenshot
      # puts "calling new take screenshot"
      if $testwise_screenshot_supported && is_windows?
        # puts "testwise supported: #{$testwise_screenshot_supported}"
        begin
          screenshot_image_filename =  "screenshot_" + Time.now.strftime("%m%d%H%M%S") + ".jpg"
          the_dump_dir = default_dump_dir
          FileUtils.mkdir_p(the_dump_dir) unless File.exists?(the_dump_dir)
          screenshot_image_filepath = File.join(the_dump_dir, screenshot_image_filename)
          screenshot_image_filepath.gsub!("/", "\\") if is_windows?

          FileUtils.rm_f(screenshot_image_filepath) if File.exist?(screenshot_image_filepath)

          if is_firefox? then
            Win32::Screenshot::Take.of(:window, :title => /mozilla\sfirefox/i).write(screenshot_image_filepath)					
					elsif ie
            Win32::Screenshot::Take.of(:window, :title => /internet\sexplorer/i).write(screenshot_image_filepath)					
          else
            Win32::Screenshot::Take.of(:foreground).write(screenshot_image_filepath)
          end
          notify_screenshot_location(screenshot_image_filepath)
        rescue => e
          puts "error on taking screenshot: #{e}"
        end
      end
    end

		# end of methods

  end

end

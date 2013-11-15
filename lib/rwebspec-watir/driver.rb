# convenient methods to drive the browser.
# convenient methods to drive the browser.
#
# Instead of
#    browser.click_button("submit")
# You can just use
#    click_button("submit")
#
require File.join(File.dirname(__FILE__), '../plugins/testwise_plugin')
require File.join(File.dirname(__FILE__), '../rwebspec-common/popup')
require File.join(File.dirname(__FILE__), '../rwebspec-common/matchers', "contains_text.rb")

require 'timeout'
require 'uri'

# require 'watir/screen_capture' if RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw")

module RWebSpec
  module Driver
    include RWebSpec::TestWisePlugin
    include RWebSpec::Popup

    # open a browser, and set base_url via hash, but does not acually
    #
    # example:
    #   open_browser :base_url => http://localhost:8080
    #
    # There are 3 ways to set base url
    #   1. pass as first argument
    #   2. If running using TestWise, used as confiured
    #   3. Use default value set
    def open_browser_by_watir(options = {})

      begin
        support_unicode
      rescue => e
        puts "Unicode may not work in IE, #{e}"
      end

			if options && options.class == String
			  options = {:base_url => options.to_s }
			end
			      
			if options && options.class == Hash && options[:base_url]
      	base_url ||= options[:base_url]
			end
			
			base_url = options[:base_url] rescue nil  
			base_url ||= $TESTWISE_PROJECT_BASE_URL			
      base_url ||= $BASE_URL
      
      raise "base_url must be set" if base_url.nil?

      default_options = {:speed => "fast",
                         :visible => true,
                         :highlight_colour => 'yellow',
                         :close_others => true,
                         :start_new => false, # start a new browser always
                         :go => true}

      options = default_options.merge options
      ($TESTWISE_HIDE_BROWSER) ? $HIDE_IE = true : $HIDE_IE = false

      if base_url =~ /^file:/
        uri_base = base_url
      else
        uri = URI.parse(base_url)
        uri_base = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      end

      if options[:start_new]
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
        # @web_browser.close_browser unless $TESTWISE_LEAVE_BROWSER_OPEN_AFTER_RUN
        @web_browser.close_browser
      else
				close_all_browsers
      end
    end
    alias close_ie close_browser


    # Close all opening browser windows
    #
    def close_all_browsers
			@web_browser.close_all_browsers
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

    # Go to another page on the testing site.
    #
    #  open_browser(:base_url => "http://www.itest2.com")
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
    #  open_browser(:base_url => "http://www.itest2.com")
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
            base_url = $TESTWISE_PROJECT_BASE_URL || $TESTWISE_PROJECT_BASE_URL || $BASE_URL
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
    #     use_current_watir_browser(:title, /.*/) # use what ever browser window
    #     use_current_watir_browser(:title, "TestWise") # use browser window with title "TestWise"    
    def use_current_watir_browser(how = :title, what = /.*/)
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
    [:area, :button, :td, :checkbox, :div, :form, :frame, :h1, :h2, :h3, :h4, :h5, :h6, :hidden, :image, :li, :link, :map, :pre, :tr, :radio, :select_list, :span, :table, :text_field, :paragraph, :file_field, :label].each do |method|
      define_method method do |* args|
        perform_operation { @web_browser.send(method, * args) if @web_browser }
      end
    end
    alias cell td
    alias check_box checkbox # seems watir doc is wrong, checkbox not check_box
    alias row tr
    alias a link
    alias img image


    [:back, :forward, :refresh, :execute_script].each do |method|
      define_method(method) do
        perform_operation { @web_browser.send(method) if @web_browser }
      end
    end
    alias refresh_page refresh
    alias go_back back
    alias go_forward forward

    [:images, :links, :buttons, :select_lists, :checkboxes, :radios, :text_fields, :divs, :dls, :dds, :dts, :ems, :lis, :maps, :spans, :strongs, :ps, :pres, :labels, :tds, :trs].each do |method|
      define_method method do
        perform_operation { @web_browser.send(method) if @web_browser }
      end
    end
		alias as links
		alias rows trs
		alias cells tds 
		alias imgs images

	
    # Check one or more checkboxes with same name, can accept a string or an array of string as values checkbox, pass array as values will try to set mulitple checkboxes.
    #
    # page.check_checkbox('bad_ones', 'Chicken Little')
    # page.check_checkbox('good_ones', ['Cars', 'Toy Story'])
    #
    [:set_form_element, :click_link_with_text, :click_link_with_id, :submit, :click_button_with_id, :click_button_with_name, :click_button_with_caption, :click_button_with_value, :click_radio_option, :clear_radio_option, :check_checkbox, :uncheck_checkbox, :select_option, :element].each do |method|
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
    #
    # params opts takes :appending => true or false, if true, won't clear the text field.
    def enter_text_with_id(textfield_id, value, opts = {})
      # For IE10, it seems unable to identify HTML5 elements
      #
      # However for IE10, the '.' is omitted.
      if opts.nil? || opts.empty?
        # for Watir, default is clear 
        opts[:appending] = false
      end
      
      perform_operation {
        
        begin
          text_field(:id, textfield_id).set(value)
        rescue => e
          # However, this approach is not reliable with Watir (IE)
          # for example, for entering email, the dot cannot be entered, try ["a@b", :decimal, "com"]
          the_elem = element(:xpath, "//input[@id='#{textfield_id}']")        
          the_elem.send_keys(:clear) unless opts[:appending]        
          the_elem.send_keys(value)        
        end
      }
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
      if ($TESTWISE_RUNNING_SPEC_ID && $TESTWISE_WORKING_DIR) || ($TESTWISE_RUNNING_SPEC_ID && $TESTWISE_WORKING_DIR)

        $TESTWISE_DUMP_DIR = $TESTWISE_DUMP_DIR = File.join($TESTWISE_WORKING_DIR, "dump")
        FileUtils.mkdir($TESTWISE_DUMP_DIR) unless File.exists?($TESTWISE_DUMP_DIR)

        spec_run_id = $TESTWISE_RUNNING_SPEC_ID || $TESTWISE_RUNNING_SPEC_ID
        spec_run_dir_name = spec_run_id.to_s.rjust(4, "0") unless spec_run_id == "unknown"
        to_dir = File.join($TESTWISE_DUMP_DIR, spec_run_dir_name)
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

    # Return page HTML with absolute references of images, stylesheets and javascripts
    # 
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

    # absolutize_page using hpricot
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
    def wait_until(timeout = $testwise_polling_timeout || 30, polling_interval = $testwise_polling_interval || 1, & block)
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
    def ajax_wait_for_element(element_id, seconds, status='show', check_interval = $testwise_polling_interval)
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
    def wait_for_element(element_id, timeout = $testwise_polling_timeout, interval = $testwise_polling_interval)
      start_time = Time.now
      #TODO might not work with Firefox
      until @web_browser.element_by_id(element_id) do
        sleep(interval)
        if (Time.now - start_time) > timeout
          raise RuntimeError, "failed to find element: #{element_id} for max #{timeout}"
        end
      end
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
        file_field(:name, file_field_name).set(normalized_file_path)
      else
        # for firefox, just call file_field, it may fail
        file_field(:name, file_field_name).set(normalized_file_path)
      end
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

    def basic_authentication(username, password, options = {})
      basic_authentication_ie(options[:title], username, password, options)
    end
    
    # TODO: Common driver module =>  this is shared by both Watir and Selenium
    #


  # TODO: Common driver module =>  this is shared by both Watir and Selenium
  #

  # use win32screenshot library or Selenium to save curernt active window
  #
  # opts[:to_dir] => the direcotry to save image under
  def take_screenshot(to_file = nil, opts = {})
    # puts "calling new take screenshot: #{$screenshot_supported}"
    # unless $screenshot_supported
    #   puts " [WARN] Screenhost not supported, check whether win32screenshot gem is installed" 
    #   return
    # end

    if to_file
      screenshot_image_filepath = to_file
    else
      screenshot_image_filename =  "screenshot_" + Time.now.strftime("%m%d%H%M%S") + ".jpg"
      the_dump_dir = opts[:to_dir] || default_dump_dir
      FileUtils.mkdir_p(the_dump_dir) unless File.exists?(the_dump_dir)
      screenshot_image_filepath = File.join(the_dump_dir, screenshot_image_filename)
      screenshot_image_filepath.gsub!("/", "\\") if is_windows?

      FileUtils.rm_f(screenshot_image_filepath) if File.exist?(screenshot_image_filepath)
    end

        begin       
          if is_firefox? then
            Win32::Screenshot::Take.of(:window, :title => /mozilla\sfirefox/i).write(screenshot_image_filepath)					
		      elsif ie
            Win32::Screenshot::Take.of(:window, :title => /internet\sexplorer/i).write(screenshot_image_filepath)					
          else
            Win32::Screenshot::Take.of(:foreground).write(screenshot_image_filepath)
          end
          notify_screenshot_location(screenshot_image_filepath)
				rescue ::DL::DLTypeError => de
					puts "No screenshot libray found: #{de}"
        rescue => e
          puts "error on taking screenshot: #{e}"
        end
    

  end

	 # end of methods

  end

end

#***********************************************************
#* Copyright (c) 2006, Zhimin Zhan.
#* Distributed open-source, see full license in MIT-LICENSE
#***********************************************************
require File.join(File.dirname(__FILE__), 'assert')
require File.join(File.dirname(__FILE__), 'driver')
require 'fileutils'

module RWebUnit

  # WebPage (children of AbstractWebPage) encapsulates a real web page.
  # For example,
  #  beginAt("/home")
  #  @web_browser.clickLinkWithText("/login")
  #  @web_browser.setFormElement("username", "sa")
  # Can be rewritten to
  #  begin_at("/home")
  #  home_page = HomePage.new
  #  login_page = home_page.clickLoginLink
  #  login_page.enterUserName("sa")
  #
  # So you only need change in LoingPage class if UI changes, which happen quite often.
  class AbstractWebPage

    include RWebUnit::Assert
    include RWebUnit::Driver

    # browser: passed to do assertion within the page
    # page_text: text used to identify the page, title will be the first candidate
    attr_accessor :page_text

    def initialize(the_browser, page_text=nil)
      @web_browser = the_browser
      @web_tester = the_browser
      @page_text = page_text
      begin
        snapshot if $ITEST_DUMP_PAGE
        delay = $ITEST_PAGE_DELAY
        sleep(delay)
      rescue => e
      end
      assert_on_page
    end

    def browser
      @web_browser
    end

    def assert_on_page()
      assert_text_present(@page_text) if @page_text
    end

    def assert_not_on_page()
      assert_text_not_present(@page_text) if @page_text
    end

    def dump(stream = nil)
      @web_browser.dump_response(stream)
    end

    def source
      @web_browser.page_source
    end

    def title
      @web_browser.page_title
    end

    # TO validate
    def contains?(ary)
      page_source = source
      found = false
      ary.each do |str|
        found ||= page_source.include?(str)
      end
      return found
    end
    alias include contains?


    def	snapshot
      if $ITEST_DUMP_DIR
        spec_run_id = $ITEST_RUNNING_SPEC_ID || "unknown"
        spec_run_dir_name = spec_run_id.to_s.rjust(4, "0") unless spec_run_id == "unknown"
        spec_run_dir = File.join($ITEST_DUMP_DIR, spec_run_dir_name)
        Dir.mkdir(spec_run_dir) unless File.exists?(spec_run_dir)
        file_name = Time.now.strftime("%m%d%H%M%S") + "_" + self.class.name.gsub("", "") + ".html"
        file = File.join($ITEST_DUMP_DIR, spec_run_dir_name, file_name)
        page_source = browser.page_source
        File.new(file, "w").puts source
      end
    end

  end

end

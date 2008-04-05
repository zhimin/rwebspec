#***********************************************************
#* Copyright (c) 2006, Zhimin Zhan.
#* Distributed open-source, see full license in MIT-LICENSE
#***********************************************************
require File.join(File.dirname(__FILE__), 'assert')
require File.join(File.dirname(__FILE__), 'driver')

module RWebUnit

  # WebPage (children of AbstractWebPage) encapsulates a real web page.
  # For example,
  #  beginAt("/home")
  #  @browser.clickLinkWithText("/login")
  #  @browser.setFormElement("username", "sa")
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
    attr_accessor :browser, :page_text

    def initialize(web_tester, page_text=nil)
      @web_tester = web_tester
      @page_text = page_text
      begin
        delay = ENV['ITEST_PAGE_DELAY'].to_i
        sleep(delay)
      rescue => e
      end      
      assert_on_page
    end

    def browser
      @web_tester
    end

    def assert_on_page()
      assert_text_present(@page_text) if @page_text
    end

    def assert_not_on_page()
      assert_text_not_present(@page_text) if @page_text
    end

    def dump(stream = nil)
      @web_tester.dump_response(stream)
    end

    def source
      @web_tester.page_source
    end

    def title
      @web_tester.page_title
    end

    def expect_page(page_clazz)
      page_clazz.new(@web_tester)
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

  end

end

require 'rubygems'
require "spec"
require 'uri'

require File.join(File.dirname(__FILE__), "..", "lib/rspec_extensions.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/driver.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/context.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/web_browser.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/web_page.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/assert.rb")
require File.join(File.dirname(__FILE__), "..", "lib/watir_extensions.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/web_page.rb")
require 'test/unit/assertions'

$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebspec")

require File.dirname(__FILE__) + "/stack"
require File.dirname(__FILE__) + "/mock_page"

class TestPage < RWebSpec::AbstractWebPage
    
    def initialize(browser)
        super(browser, "iTest2/Watir Test Page")
    end
    
end

specification "Driver" do
  include RWebSpec::Driver
  include RWebSpec::Assert

  before(:all) do
    test_page_file = "file://" + File.expand_path(File.join(File.dirname(__FILE__), "test_page.html"))
    browser = open_browser(test_page_file, {:firefox => true})
    @test_page = TestPage.new(browser)
  end

  story "assert on page, title" do
    @test_page.assert_on_page
    @test_page.page_specific_text.should == "iTest2/Watir Test Page"  
    @test_page.title.should == "For Testing iTest2"
  end
  
  story "assertion" do
    @test_page.text.should contains("iTest2/Watir Test Page") 
    @test_page.text.should_not contains("iTest/Watir Test Page") 
    @test_page.html.should  contains("Text (with name, just <i>id</i>):") 
    @test_page.text.should_not contains("Text (with name, just <i>id</i>):")     
  end
end
#END

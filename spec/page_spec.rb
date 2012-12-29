# require 'rubygems'
# require "spec"
# require 'uri'
# 
# require File.join(File.dirname(__FILE__), "..", "lib/extensions/rspec_extensions.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/driver.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/context.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/web_browser.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/web_page.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/assert.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/extensions/watir_extensions.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/web_page.rb")
# require 'test/unit/assertions'
# 
# $:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebspec")

require File.join(File.dirname(__FILE__), "spec_helper.rb")

require File.dirname(__FILE__) + "/stack"
require File.dirname(__FILE__) + "/mock_page"

class TestPage < RWebSpec::AbstractWebPage

  def initialize(browser)
    super(browser, "iTest2/Watir Test Page")
  end

end

specification "Page objects" do
  include RWebSpec::Driver
  include RWebSpec::Assert
  include RWebSpec::Utils

  before(:all) do
    test_page_file = "file://" + File.expand_path(File.join(File.dirname(__FILE__), "test_page.html"))
		if RWebSpec.framework == "Selenium" || RUBY_PLATFORM =~ /darwin/
    	@browser = open_browser(test_page_file, {:browser => :firefox})
		else
    	@browser = open_browser(test_page_file)			
		end
		
    @test_page = TestPage.new(browser)
  end

	after(:all) do
		close_browser
	end
	
  story "assert on page, title" do
    @test_page.assert_on_page
    @test_page.page_specific_text.should == "iTest2/Watir Test Page"
    @test_page.title.should == "For Testing iTest2"
  end

  story "assertion" do
    @test_page.text.should contains("iTest2/Watir Test Page")
    @test_page.text.should contain("iTest2/Watir Test Page")
    @test_page.text.should_not contain("iTest/Watir Test Page")
    begin
      @test_page.html.should contains("Text (with name, just <i>id</i>):")
    rescue => e
      @test_page.html.should contains("Text (with name, just <I>id</I>):")
    end
    @test_page.text.should_not contains("Text (with name, just <i>id</i>):")
  end

	story	"page url" do
		 @test_page.url.should include("spec/test_page.html")
	end
	
end
#END

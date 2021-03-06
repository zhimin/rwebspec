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
# require 'test/unit/assertions'
# 
# $:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebspec")

require File.join(File.dirname(__FILE__), "spec_helper.rb")

require File.dirname(__FILE__) + "/stack"
require File.dirname(__FILE__) + "/mock_page"

specification "Driver" do
  include RWebSpec::RSpecHelper


  before(:all) do
    test_page_file = "file://" + File.expand_path(File.join(File.dirname(__FILE__), "test_page.html"))
		if RWebSpec.framework == "Selenium" || RUBY_PLATFORM =~ /darwin/
    	open_browser(:base_url => test_page_file, :browser => :chrome)
		else
    	open_browser(test_page_file)			
		end
  end

	after(:all) do
		close_browser unless debugging?
	end

  #ABC
  story "expect_page" do
    new_page = expect_page MockPage
  end


  story "fail_safe" do
    fail_safe {raise "X"}
  end

  story "on(...)" do
    page = []
    on(page) do |i|
      i << "0"
      i << "1"
    end
    assert_equal(["0", "1"], page)
  end

  story "shall_not_allow" do
    shall_not_allow {1 / 0}
  end

  story "allowing" do
    begin
      allowing { 1 / 0}
      fail "error should have been thrown"    
    rescue ZeroDivisionError => e
      # puts "Y: #{e.class}"
    end
  end

  story "symbol_to_sequence" do
    assert_equal 1, symbol_to_sequence(:first)
    assert_equal 2, symbol_to_sequence(:second)
    assert_equal 11, symbol_to_sequence(11)
  end

  story "wait_util" do
    click_button("Transfer")
    wait_until(11, 2) { label(:id, "date").exists? }
  end

  story "click button with image" do
    click_button_with_image("search_button.gif")
    go_back
    refresh
  end

  story "try" do
    try_for(100) { 2 > 1} # if will get out quickly
    begin
      try_for(2) { 1 / 0}
    rescue => e
      assert_equal("Timeout after 2 seconds with error: divided by 0.", e.to_s)
    end

    begin
      try_for(2) { 1 > 2}
    rescue => e
      assert_equal("Timeout after 2 seconds.", e.to_s)
    end
  end

  story "save_current_page" do
    save_current_page(:dir => "/tmp", :filename => "rwebspec_dump.html", :replacement => true)
  end

  story "absolutize_page hprioct" do
    html = File.read(File.join(File.dirname(__FILE__), "0730161114_MyOrganizedMainPage.html"))
    base_url = "http://myorganized.agileway.net"
    current_url_parent = "/"
    ret_page = absolutize_page_hpricot(html, base_url, current_url_parent)
    ret_page.should include("http://myorganized.agileway.net/stylesheets/wenji.css")
    # File.open("tmp.html", "w").puts ret_page
  end
  
  story "assertion" do
    page_text.should include("iTest2/Watir Test Page")
    page_text.should contains("iTest2/Watir Test Page") 
    page_text.should_not contains("iTest/Watir Test Page") 
    page_text.should_not contains("iTest/Watir Test Page") 
  end
  
  story "with index options" do
    label(:id, "label1").text.should == label_with_id("label1")
    label_with_id("label1").should == "First Label"
    label_with_id("label1", :index => 2).should == "Actually Second Label"
    span_with_id("span1").should == "First Span"
    span_with_id("span1", :index => 2).should == "Actually Second Span"
    
    click_link("Click Me", :index => 2)
    assert_visible(:div, "for_link_2")
    click_link("Click Me", :index => 1)
    assert_visible(:div, "for_link_1") 

    click_link_with_id("alink", :index => 2)
    assert_visible(:div, "for_link_2")
    click_link_with_id("alink",:index => 1)
    assert_visible(:div, "for_link_1") 
    
    click_button("Click Button", :index => 2)
    assert_visible(:div, "for_link_2")
    click_button("Click Button", :index => 1)
    assert_visible(:div, "for_link_1") 
    
    click_button_with_id("abutton", :index => 2)
    assert_visible(:div, "for_link_2")
    click_button_with_id("abutton",:index => 1)
    assert_visible(:div, "for_link_1") 
  end
  
  story "Check checkbox" do
    check_checkbox("checkbox1")
    assert_checkbox_selected("checkbox1")    
    check_checkbox("checkbox2", "true")
    assert_checkbox_selected("checkbox2")
  end

  
  story "Uncheck checkbox" do
    check_checkbox("checkbox1")
    assert_checkbox_selected("checkbox1")
    uncheck_checkbox("checkbox1")
    assert_checkbox_not_selected("checkbox1")
    
    check_checkbox("checkbox2", "true")
    uncheck_checkbox("checkbox2", "true")
    assert_checkbox_not_selected("checkbox2")

  end
end
#END

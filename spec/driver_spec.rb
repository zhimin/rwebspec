require 'rubygems'
require "spec"
require 'uri'

require File.join(File.dirname(__FILE__), "..", "lib/rspec_extensions.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebunit/driver.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebunit/context.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebunit/web_browser.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebunit/web_page.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebunit/assert.rb")
require File.join(File.dirname(__FILE__), "..", "lib/watir_extensions.rb")
require 'test/unit/assertions'

$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebunit")

require File.dirname(__FILE__) + "/stack"
require File.dirname(__FILE__) + "/mock_page"

specification "Driver" do
  include RWebUnit::Driver
  include RWebUnit::Assert

  before(:all) do
    test_page_file = "file://" + File.expand_path(File.join(File.dirname(__FILE__), "test_page.html"))
    open_browser(test_page_file, {:firefox => true})
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
    try(100) { 2 > 1} # if will get out quickly
    begin
      try(2) { 1 / 0}
    rescue => e
      assert_equal("Timeout after 2 seconds with error: divided by 0.", e.to_s)
    end

    begin
      try(2) { 1 > 2}
    rescue => e
      assert_equal("Timeout after 2 seconds.", e.to_s)
    end
  end

  story "save_current_page" do
    save_current_page(:dir => "/tmp", :filename => "rwebunit_dump.html", :replacement => true)
  end

  story "absolutize_page hprioct" do
    html = File.read(File.join(File.dirname(__FILE__), "0730161114_MyOrganizedMainPage.html"))
    base_url = "http://myorganized.agileway.net"
    current_url_parent = "/"
    ret_page = absolutize_page_hpricot(html, base_url, current_url_parent)
    ret_page.should include("http://myorganized.agileway.net/stylesheets/wenji.css")
    # File.open("tmp.html", "w").puts ret_page
  end

end
#END

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

describe "Assertion" do
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

  it "Assert nil" do
    value = nil
    assert_nil value
    assert_nil(value)
    begin
      assert_not_nil(value, "error text")
    rescue => e
      assert_equal("error text.\n<false> is not true.", e.to_s)
    end
  end

  it "fail" do
    begin
      fail("I can't do it")
    rescue => e
      assert_equal("I can't do it.\n<false> is not true.".strip, e.to_s.strip)
    end
  end

  it "assert_text_prsent" do
    assert_text_present("iTest2/Watir Test Page")
    assert_text_not_present("Watir Test Page2")
  end

  it "assert_title" do
    assert_title("For Testing iTest2")
  end

  it "assert_link_present_with_text" do
    assert_link_present_with_text("iTest2 with Id")
    assert_link_not_present_with_text("iTest2 with id")
    assert_link_not_present_with_text("XX")

    assert_link_present_with_exact("iTest2 with Id")
    assert_link_not_present_with_exact("iTest2 with I")
  end

  it "assert_checkbox_selected" do
    assert_checkbox_not_selected("checkbox1")
    check_checkbox("checkbox1")
    assert_checkbox_selected("checkbox1")
    uncheck_checkbox("checkbox1")
    assert_checkbox_not_selected("checkbox1")
  end


  scenario "assert_radio_option_present" do
    assert_radio_option_present("os", "Linux")
    assert_radio_option_present("os","Apple")
    assert_radio_option_not_present("os","Windows")
    click_radio_option("os", "Linux")
    assert_radio_option_selected("os", "Linux")
  end

  scenario "assert_button_present" do
    assert_button_present("login-btn")
    assert_button_not_present("login-Btn")
    assert_button_present_with_text("Login")
    assert_button_not_present_with_text("login")
  end

  scenario "assert_option_value_present" do
    assert_option_value_present("testing_tool", "Watir")
    assert_option_value_present("testing_tool", "iTest2")
    assert_option_present("testing_tool", "iTest2 display")
    select_option("testing_tool", "Watir")
    select_option("testing_tool", "iTest2 display")
    assert_option_equals("testing_tool", "iTest2 display")
    assert_option_value_equals("testing_tool", "iTest2")
  end

  it "assert_exists, assert_not" do
    # Watir vway assert div(:id, "info").exists?
    # assert_not div(:id, "not_there").exists?
    assert_exists(:div, "info")
    assert_not_exists(:div, "not_there_xxx")
  end

  
  it "assert_table" do
    if RWebSpec.framework == "Selenium"
      assert_text_present_in_table("alpha_table", "A B", :just_plain_text => true)  # => true
    else
      assert_text_present_in_table("alpha_table", "AB", :just_plain_text => true)  # => true
    end
    assert_text_present_in_table("alpha_table", ">A<")  # => true
    assert_text_not_present_in_table("alpha_table", ">A<", :just_plain_text => true)  # => false
    # assert table(:id, :alpha_table).innerHTML.include?(">A<")
  end

  it "assert_text_field_value" do
    assert_text_field_value("text1", "text already there")
  end

  it "using try_for with assertion" do
    click_link_with_id("choose_tool_link")
    try_for(3) { assert_option_value_equals("favourite_tool", "TestWise") }
  end

  scenario "Ajax - show or hide text, assert visible? (not working on Mac)" do
    click_link("Hide info")
    sleep 0.5
    assert_hidden(:div, "info")
    click_link("Show info")
    sleep 0.5
    assert_visible(:div, "info")
  end


  it "Assert select list options" do
    select_option("testing_tool", "Watir")
    select_option("testing_tool", "iTest2 display")
    assert_menu_value("testing_tool", "iTest2")
    assert_menu_label("testing_tool", "iTest2 display")
    assert_option_present("testing_tool", "iTest2 display")
    assert_option_present("testing_tool", "Watir")
    assert_option_not_present("testing_tool", "Selenium")
  end
end

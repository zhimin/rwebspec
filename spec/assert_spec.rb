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

describe "Assertion" do
  include RWebUnit::Driver
  include RWebUnit::Assert

  before(:all) do
    test_page_file = "file://" + File.expand_path(File.join(File.dirname(__FILE__), "test_page.html"))
    open_browser(test_page_file, {:firefox => true})
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
    assert_text_present("<h1>iTest2/Watir Test Page</h1>")
    assert_text_not_present("<h1>Watir Test Page</h1>")
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

  # scenario "Ajax - show or hide text, assert visible? (not working on Mac)" do
  #   click_link("Hide info")
  #   sleep 0.5
  #   # FIXME Check visiblity doesn not work on Firefox yet
  #   assert !div(:id, "info").visible?
  #   assert_hidden(:div, "info")
  #   click_link("Show info")
  #   sleep 0.5
  #   assert_visible(:div, "info")
  #   assert div(:id, "info").visible?
  # end

  it "assert_exists, assert_not" do
    assert div(:id, :info).exists?
    assert_not div(:id, :not_there).exists?
    assert_exists(:div, :info)
  end

  it "assert_table" do
    assert_text_present_in_table("alpha_table", ">A<")  # => true
    assert_text_present_in_table("alpha_table", "A B", :just_plain_text => true)  # => true
    assert_text_not_present_in_table("alpha_table", ">A<", :just_plain_text => true)  # => false
    # assert table(:id, :alpha_table).innerHTML.include?(">A<")
  end

  it "assert_text_field_value" do
    assert_text_field_value("text1", "text already there")
  end
  
end
#END

require 'rubygems'
require 'firewatir'

$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebunit")
$:.unshift File.dirname(__FILE__)

require "test_utils"
require "web_page"
require "assert"
require "itest_plugin"
require "web_browser"
require "driver"
require "context"
require "driver"
require "rspec_helper"
require 'test/unit'
require 'setup'

class TestDriver < Test::Unit::TestCase
  include RWebUnit::Utils
  include RWebUnit::RSpecHelper

  def setup
    @web_browser = $web_browser
  end

  def teardown
  end

  def test_assert_text
    assert_text_present("iTest2/Watir Recorder Test Page")
    assert_text_not_present("iTest3/Watir Recorder Test Page")
  end

  def test_assert_link
    assert_link_present_with_text("iTest2 with Id")
    assert_link_not_present_with_text("iTest2 with id")
    assert_link_not_present_with_text("XX")
  end

  def test_checkbox
    assert_checkbox_not_selected("checkbox1")
    check_checkbox("checkbox1")
    assert_checkbox_selected("checkbox1")
    uncheck_checkbox("checkbox1")
    assert_checkbox_not_selected("checkbox1")
  end

  def test_radiobutton
    assert_radio_option_present("os", "Linux")
    assert_radio_option_present("os","Apple")
    assert_radio_option_not_present("os","Windows")
    click_radio_option("os", "Linux")
    assert_radio_option_selected("os", "Linux")
  end

  def test_button
    assert_button_present("login-btn")
    assert_button_not_present("login-Btn")
    assert_button_present_with_text("Login")
    assert_button_not_present_with_text("login")
  end

end

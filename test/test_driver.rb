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
require 'mock_page'

class TestDriver < Test::Unit::TestCase
  include RWebUnit::Driver

  def setup
    @web_browser = $web_browser
  end

  def teardown
  end

  def test_fail_safe
    fail_safe {raise "X"}
  end

  def test_expect_page
    new_page = expect_page MockPage
    assert_equal("dummy", new_page)
  end

  def test_on
    page = []
    on(page) do |i|
      i << "0"
      i << "1"
    end
    assert_equal(["0", "1"], page)
  end

  def test_shall_not_allow
    shall_not_allow {1 / 0}
  end

  def test_symbol_to_sequence
    assert_equal 1, symbol_to_sequence(:first)
    assert_equal 2, symbol_to_sequence(:second)
    assert_equal 11, symbol_to_sequence(11)
  end

end

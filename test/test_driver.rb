$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebunit")
$:.unshift File.dirname(__FILE__)

require "driver.rb"
require "web_tester.rb"
require 'test/unit'

class TestDriver < Test::Unit::TestCase
  include RWebUnit::Driver

  def setup
    @web_tester = "dummy"
  end

  def teardown
  end

  def test_fail_safe
    fail_safe {raise "X"}
  end

  def test_expect_page
    new_page = expect_page String
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
    shall_allow { 0/1}  
  end
end

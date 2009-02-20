require 'rubygems'
require "spec"
require File.join(File.dirname(__FILE__), "..", "lib/rspec_extensions.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebunit/driver.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebunit/web_page.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebunit/assert.rb")
require 'test/unit/assertions'

$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebunit")

require File.dirname(__FILE__) + "/stack"
require File.dirname(__FILE__) + "/mock_page"

specification "Driver" do
  include RWebUnit::Driver
  include RWebUnit::Assert

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

  story "symbol_to_sequence" do
    assert_equal 1, symbol_to_sequence(:first)
    assert_equal 2, symbol_to_sequence(:second)
    assert_equal 11, symbol_to_sequence(11)
  end

end
#END

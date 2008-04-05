#$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebunit")

require "rwebunit"

$:.unshift File.dirname(__FILE__)
require "kangxi_pages.rb"

class TestHttpCaller < RWebUnit::WebTestCase

   def initialize(name)
      super(name)
   end

   def setup
      super
      getTestContext().base_url = "http://localhost:3721"
      beginAt("/http")
   end

   def teardown
      super
      closeBrowser()
   end

   def test_can_display()
      kangxi_httpcaller_page = KangxiHttpCallerPage.new(@web_tester)
      @web_tester.assertOptionValuePresent("method", "POST")
      @web_tester.assertOptionValuePresent("method", "GET")

   end


end

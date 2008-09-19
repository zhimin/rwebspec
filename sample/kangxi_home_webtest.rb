#$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebunit")

require "rwebunit"

$:.unshift File.dirname(__FILE__)
require "kangxi_pages.rb"

class TestKangxiHome < RWebUnit::WebTestCase

   def initialize(name)
      super(name)
   end

   def setup
      super
      getTestContext().base_url = "http://localhost:3721"
      beginAt("/home")
   end

   def teardown
      super
      closeBrowser()
   end

   def test_homepage_exists()
      kangxi_homepage = KangxiHomePage.new(@web_browser, "Welcome")
   end

   def test_all_links_exist
      kangxi_homepage = KangxiHomePage.new(@web_browser, "Welcome")
      kangxi_homepage.assertTheListLinkPresent()
      kangxi_homepage.assertDashboardLinkPresent
      kangxi_homepage.assertTestCenterLinkPresent
      kangxi_homepage.assertTestWebServiceLinkPresent
   end

end

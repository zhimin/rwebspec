#$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebunit")

require "rwebunit"

$:.unshift File.dirname(__FILE__)
require "kangxi_pages.rb"

class TestXmlFormatter < RWebUnit::WebTestCase

   def initialize(name)
      super(name)
   end

   def setup
      super
      getTestContext().base_url = "http://localhost:3721"
      beginAt("/home")
      kangxi_homepage = KangxiHomePage.new(@web_tester, "Welcome")
      @kangxi_xmlformatter_page = kangxi_homepage.clickXMLFormatterLink
   end

   def teardown
      super
      closeBrowser()
   end

   def test_can_invoke_format
      @kangxi_xmlformatter_page.enterXml("<name><first>James</first><last>Bond</last></name>")
      @kangxi_xmlformatter_page.clickFormat
   end

   def test_format_sample_xml
      @kangxi_xmlformatter_page.clickFillExampleLink
      @web_tester.assertElementNotPresent("formatted_xml")
      @kangxi_xmlformatter_page.submit
      @web_tester.assertElementPresent("formatted_xml")
   end

   def test_can_call_utils
      @kangxi_xmlformatter_page.enterXml("<date><now>" + getToday + "</now></date>")
      @kangxi_xmlformatter_page.clickFormat
   end

end

# the same test used in jWebUnit home page written in rWebUnit
require 'rwebunit'

class TestRWebUnitHome < RWebUnit::WebTestCase

   def initialize(name) 
      super(name)
   end

   def setup
      getTestContext().setBaseUrl("http://www.zhimin.com")
      beginAt("/")
   end

   def test_rdoc()
      setFormElement("q", "httpunit")
      submit("btnG")
      clickLinkWithText("HttpUnit Home")
      assertTitleEquals("HttpUnit Home")
      assertLinkPresentWithText("User's Manual")
   end
end

# the same test used in jWebUnit home page written in rWebUnit
require 'rwebunit'

class RWebUnitSearchExample < RWebUnit::WebTestCase

   def initialize(name)
      super(name)
   end

   def setup
      getTestContext().setBaseUrl("http://www.google.com")
   end

   def test_search()
      beginAt("/")
      setFormElement("q", "httpunit")
      submit("btnG")
      clickLinkWithText("HttpUnit Home")
      assertTitleEquals("HttpUnit Home")
      assertLinkPresentWithText("User's Manual")
   end
end

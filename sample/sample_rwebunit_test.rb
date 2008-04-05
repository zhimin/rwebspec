# a sample rwebunit test check HttpUnit home page
require 'rwebunit'

class RWebUnitSearchExample < RWebUnit::WebTestCase

   def test_search()
      getTestContext().base_url = "http://www.google.com"
      beginAt("/")
      setFormElement("q", "httpunit")
      clickButtonWithCaption("Google Search")
      clickLinkWithText("HttpUnit Home")
      assertTitleEquals("HttpUnit Home")
      assertLinkPresentWithText("User's Manual")
   end
end

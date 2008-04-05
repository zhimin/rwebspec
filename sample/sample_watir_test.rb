# a sample watir test check HttpUnit home page
require 'watir'
require 'test/unit'

class WatirSearchExample < Test::Unit::TestCase

   def test_search
      ie = Watir::IE.new
      ie.goto("http://www.google.com")
      ie.text_field(:name, "q").set("httpunit")
      ie.button(:name, "btnG").click
      ie.link(:text, "HttpUnit Home").click
      assert_equal("HttpUnit Home", ie.document.title)
      assert(ie.contains_text("User's Manual"))
   end

end

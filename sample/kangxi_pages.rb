require "rwebunit"

class KangxiHomePage < RWebUnit::AbstractWebPage

  def initialize(browser, title)
    super(browser, title)
  end

  def assertTheListLinkPresent
    @web_browser.assertLinkPresentWithText('The List')
  end

  def assertDashboardLinkPresent
    @web_browser.assertLinkPresentWithText('Dashboard')
  end

  def assertTestCenterLinkPresent
    @web_browser.assertLinkPresentWithText('Test center')
  end

  def assertTestWebServiceLinkPresent
    @web_browser.assertLinkPresentWithText('Test web service')
  end
  
  def clickXMLFormatterLink
    @web_browser.clickLinkWithText("XML Formatter")
    KangxiXMLFormatterPage.new(@web_browser, "Format XML")
  end

end

class KangxiXMLFormatterPage < RWebUnit::AbstractWebPage

  def initialize(browser, title)
    super(browser, title)
  end

  def clickFillExampleLink
    @web_browser.clickLinkWithText("Fill example")
  end

  def enterXml(inputXml)
    @web_browser.enterText("inputText", inputXml)
  end

  def clickFormat
    @web_browser.clickButtonWithValue("Format")
  end

end

class KangxiHttpCallerPage < RWebUnit::AbstractWebPage
  def initialize(browser)
    super(browser,"Http Caller")
  end
end

class KangxiCookbookPage < RWebUnit::AbstractWebPage
  def initialize(browser)
    super(browser,"code recipes")
  end
end

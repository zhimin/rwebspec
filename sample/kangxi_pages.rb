require "rwebunit"

class KangxiHomePage < RWebUnit::AbstractWebPage

  def initialize(browser, title)
    super(browser, title)
  end

  def assertTheListLinkPresent
    @browser.assertLinkPresentWithText('The List')
  end

  def assertDashboardLinkPresent
    @browser.assertLinkPresentWithText('Dashboard')
  end

  def assertTestCenterLinkPresent
    @browser.assertLinkPresentWithText('Test center')
  end

  def assertTestWebServiceLinkPresent
    @browser.assertLinkPresentWithText('Test web service')
  end
  
  def clickXMLFormatterLink
    @browser.clickLinkWithText("XML Formatter")
    KangxiXMLFormatterPage.new(@browser, "Format XML")
  end

end

class KangxiXMLFormatterPage < RWebUnit::AbstractWebPage

  def initialize(browser, title)
    super(browser, title)
  end

  def clickFillExampleLink
    @browser.clickLinkWithText("Fill example")
  end

  def enterXml(inputXml)
    @browser.enterText("inputText", inputXml)
  end

  def clickFormat
    @browser.clickButtonWithValue("Format")
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

$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebunit")

class MockPage < RWebUnit::AbstractWebPage

  def initialize(browser)
    # super(browser, "")
  end
end

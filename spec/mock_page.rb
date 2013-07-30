$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebspec")

class MockPage < RWebSpec::AbstractWebPage

  def initialize(browser)
    # super(browser, "")
  end
end

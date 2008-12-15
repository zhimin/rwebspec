require 'rwebunit'

class MockPage < RWebUnit::AbstractWebPage

  def initialize(browser)
    super(browser, "")
  end
end

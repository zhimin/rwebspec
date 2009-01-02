
class NewtoursSelectFlightPage < RWebUnit::AbstractWebPage

  def initialize(browser)
    super(browser, "Select your departure")
  end

  def click_continue
    click_button_with_image("continue.gif")
    expect_page NewtoursBookFlightPage
  end
  
end

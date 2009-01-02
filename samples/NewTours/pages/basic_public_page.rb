
class BasePublicPage < RWebUnit::AbstractWebPage

  def initialize(browser, text = "")
    super(browser, text)
  end

  def click_login()
    click_link_with_text("Login")
    expect_page LoginPage
  end

end
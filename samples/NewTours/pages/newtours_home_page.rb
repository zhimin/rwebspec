
class NewtoursHomePage < RWebUnit::AbstractWebPage

  def initialize(browser)
    super(browser, "Registered users")
  end

  def enter_user_name(user_name)
    enter_text("userName", user_name)
  end

  def enter_password(password)
    enter_text("password", password)
  end

  def click_sign_in
    click_button_with_image("btn_signin")
    expect_page NewtoursFlightFinderPage
  end

end

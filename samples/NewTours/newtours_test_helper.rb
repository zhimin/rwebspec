require 'rwebunit'
Dir[File.join(File.dirname(__FILE__), 'pages', "*_page.rb")].each { |file| load(file) }

module NewtoursTestHelper
  include RWebUnit::RSpecHelper
  include RWebUnit::Assert

  # Helper functions
  #  - extract common functions to reuse
  #  - normally done by developers
  def login_as(username, password = "agileway")
    enter_text("userName", username)
    enter_text("password", password)
    click_button_with_image("btn_signin")
  end

  def sign_off
    click_link("SIGN-OFF")
  end
  
end

require 'rwebspec'
Dir[File.join(File.dirname(__FILE__), 'pages', "*_page.rb")].each { |file| load(file) }

module MyOrganizedInfoHelper
  include RWebSpec::RSpecHelper
  include RWebSpec::Assert

  def login_as(username, password="monkey")
    enter_text("login", username)
    enter_text("password", password)
    click_button("Log in")
  end
  
end

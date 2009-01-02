require File.dirname(__FILE__) + '/test_helper.rb'

suite "Create notes" do
  include MyOrganizedInfoHelper

  before(:each) do
    open_browser_with("http://wenji.agileway.net")
  end

  after(:each) do
    login_as("zhimin")
    close_browser
  end

  test "can create a new " do
    enter_text("login", "zhimin")
    enter_text("password", "monkey")
    click_button("Log in")
  end

end

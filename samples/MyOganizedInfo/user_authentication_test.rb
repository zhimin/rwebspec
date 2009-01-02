require File.dirname(__FILE__) + '/test_helper.rb'

suite "User authentication module" do
  include MyOrganizedInfoHelper

  before(:each) do
    open_browser_with("http://wenji.agileway.net")
    @rows = FasterCSV.read("path/to/file.csv")
  end

  after(:each) do
    close_browser
    # click_button_in_popup_after { click_link_with_id("logout")}
  end

  test "Login success" do
    enter_text("login", "zhimin")
    enter_text("password", "monkey")
    click_button("Log in")
  end

  @rows.each do |row|
    test "login test for #{row["NAME"])" do
      login_as(row["USERNAME"], row["PASSWORD"])
    end
  end
  
end

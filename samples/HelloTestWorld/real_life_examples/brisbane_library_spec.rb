require 'rwebspec'

spec "Brisbane Library User Authentications" do
  include RWebUnit::RSpecHelper

  scenario "[001] Deny access if user name is not correct" do
    open_browser_with("http://elibcat.library.brisbane.qld.gov.au/uhtbin/webcat/")
    click_link("My Account")
    link(:text, "Review My Account").click
    enter_text("user_id", "24000010626")
    enter_text("password", "1234")
    click_button_with_text "View My Account"
    page_source.should include("Access denied")
    close_browser
  end

  scenario "[002] Deny access if password does not match username" do 
    open_browser_with("http://elibcat.library.brisbane.qld.gov.au/uhtbin/webcat/")
    click_link("My Account")
    link(:text, "Review My Account").click
    enter_text("user_id", "24000010626434") # valid account
    enter_text("password", "1234")
    click_button_with_text "View My Account"
    page_source.should include("Access denied")
    close_browser
  end
end

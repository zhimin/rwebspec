require 'rwebspec'

specification "JavaScript Popup Window" do
  include RWebSpec::RSpecHelper

  # Remeber to allow turn on allowing popup window setting in IE
  scenario "Click javascript confirmation popup in IE" do
    open_browser("file://" + File.join(File.dirname(File.expand_path(__FILE__)), "test_page.html"))
    button(:value, "Do you really like iTest2?").click_no_wait
    ie_popup_clicker("OK")
    click_button_with_id("complete_btn")
    close_browser
  end
  
end

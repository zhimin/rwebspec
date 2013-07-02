# load File.dirname(__FILE__) + '/test_helper.rb'

require 'rwebspec'

RWebSpec.framework = "Selenium"

test_suite "Payment" do
  include RWebSpec::RSpecHelper

  before(:all) do
    open_browser(:base_url => "http://travel.agileway.net", :browser => :firefox)
    enter_text("username", "agileway")
    enter_text("password", "test")
    click_button("Sign in")
  end

  after(:all) do
    fail_safe { click_link("Sign off")} unless debugging?
    close_browser unless debugging?
  end

  test_case "Get booking confirmation after payment " do
    visit("/")
    click_radio_option("tripType", "oneway")
    assert_hidden(:div, "returnTrip")
    select_option("fromPort", "Sydney")
    select_option("toPort", "New York")
    select_option("departDay", "02")
    if RWebSpec.framework == "Watir"
      # mixed with raw watir 
      select_list(:id, "departMonth").select("May 2012") # mixed with Watir syntax
    else
      # mixed with raw selenium
      Selenium::WebDriver::Support::Select.new(browser.find_element(:name, "departMonth")).select_by(:text, "May 2012")
    end
    click_button("Continue")

    enter_text("passengerFirstName", "Bob")
    enter_text("passengerLastName", "Tester")
    click_button("Next")

    click_radio_option("card_type", "master")
    enter_text("holder_name", "Bob  the Tester")
    enter_text("card_number", "4242424242424242")
    select_option("expiry_month", "04")
    select_option("expiry_year", "2012")
    click_button("Pay now")
    try_for(12) { page_text.should include("Booking number")}
    debug span(:id, "booking_number").text
  end

end
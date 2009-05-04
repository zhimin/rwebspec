load File.join(File.dirname(__FILE__), "newtours_test_helper.rb")

# These lines are comments (starting with #)
#
# This spec implements a secnario based on Mercury Interactive (now HP)'s tutorial
#   http://kathipurushotham.blogspot.com/2008/02/qtp-tutorials.html
#
#
suite "Flight Reservation" do
  include NewtoursTestHelper
  use :pages => :all
  
  before(:all) do
    open_browser("http://newtours.demoaut.com")
  end

  before(:each) do
    begin_at "/"
    login_as("agileway") # see bottom
  end

  after(:each) do
    failsafe { sign_off }
  end

  after(:all) do
    failsafe { browser.close if browser.is_firefox? and is_windows? }
  end
  
  # Sample Test script (VB Script) in QuickTest Pro
  #
  #      Browser("Welcome: Mercury Tours").Page("Find a Flight: Mercury").WebList("fromPort").Select "New York"
  #      Browser("Welcome: Mercury Tours").Page("Find a Flight: Mercury").WebList("fromMonth").Select "December"
  #      Browser("Welcome: Mercury Tours").Page("Find a Flight: Mercury").WebList("fromDay").Select "31"
  #      Browser("Welcome: Mercury Tours").Page("Find a Flight: Mercury").WebList("toPort").Select "San Francisco"
  #      Browser("Welcome: Mercury Tours").Page("Find a Flight: Mercury").WebList("toMonth").Select "December"
  #      Browser("Welcome: Mercury Tours").Page("Find a Flight: Mercury").WebList("toDay").Select "31"
  #      Browser("Welcome: Mercury Tours").Page("Find a Flight: Mercury").Image("findFlights").Click 55,12
  #      Browser("Welcome: Mercury Tours").Page("Select a Flight: Mercury").Image("reserveFlights").Click 31,10
  #      Browser("Welcome: Mercury Tours").Page("Book a Flight: Mercury").WebEdit("passFirst0").Set "Xindi"
  #      Browser("Welcome: Mercury Tours").Page("Book a Flight: Mercury").WebEdit("passLast0").Set "Fu"
  #      Browser("Welcome: Mercury Tours").Page("Book a Flight: Mercury").WebEdit("creditnumber").Set "6534 7865 1234 3"
  #      Browser("Welcome: Mercury Tours").Page("Book a Flight: Mercury").Image("buyFlights").Click 72,10
  #      Browser("Welcome: Mercury Tours").Page("Flight Confirmation: Mercury").Image("backtoflights").Click
  #
  #  Checkpoints not be seen in expert views


  # The is test script is recorded using iTest Plugin for Firefox plus
  # assertions (or check points in QTP's term).
  test "QTP Tutorial 1:  Book Flight" do
    select_option("fromPort", "New York")
    select_option("fromMonth", "December")
    select_option("fromDay", "29")
    select_option("toPort", "San Francisco")
    select_option("toMonth", "December")
    select_option("toDay", "31")
    click_radio_option("servClass", "Business")
    click_button_with_image("continue.gif")

    click_button_with_image("continue.gif")

    enter_text("passFirst0", "iTest")
    enter_text("passLast0", "AgileWay")
    enter_text("creditnumber", "123456781234567")
    check_checkbox("ticketLess", "checkbox")
    click_button_with_image("purchase.gif")

    page_source.should include("New York to San Francisco")
    page_source.should include("San Francisco to New York")
    assert_text_present("1 passenger")
    page_source.should include("Ticketless Travel")
  end

  # Refactor the above test to a more maintainable way by moving
  # operations to xxx_page.rb under pages/ folder, so that
  #  * if modfications (who doesn't) made to web pages, just need to change once
  #  * define you own testing syntax
  #  * iTest IDE take advantage of this design/debug to make devleoping test easier
  test "QTP Tutorial 1 (Refactored version): Book flight using Page object design" do
    flight_finder_page = expect_page NewtoursFlightFinderPage
    flight_finder_page.select_departing_from("New York")
    flight_finder_page.select_departing_month("December")
    flight_finder_page.select_departing_day("29")
    flight_finder_page.select_arriving_in("San Francisco")
    flight_finder_page.select_returning_month("December")
    flight_finder_page.select_returning_day("31")
    flight_finder_page.select_service_class("Business")
    select_flight_page = flight_finder_page.click_continue

    book_flight_page = select_flight_page.click_continue
    book_flight_page.enter_first_name "iTest"
    book_flight_page.enter_last_name "AgileWay"
    book_flight_page.enter_credit_card_number "123456781234567"
    book_flight_page.check_ticketless_travel
    book_flight_page.click_secure_purchase

    page_source.should include("itinerary has been booked!")
    page_source.should include("New York to San Francisco")
    page_source.should include("San Francisco to New York")
    assert_text_present("1 passenger")
    page_source.should include("Ticketless Travel")
  end


end

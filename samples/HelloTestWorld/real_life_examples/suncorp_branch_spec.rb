require 'rwebunit'

spec "Locate a Suncorp Branch" do
  include RWebUnit::RSpecHelper

  before(:all) do
    open_browser_with("http://suncorp.com.au/")
  end

  before(:each) do
    goto_page("/locator")
  end

  after(:all) do
    close_browser
  end

  scenario "Find by postcode" do
    enter_text("Postcode_Locator__Postcode", "4061")
    click_button_with_image("search_button.gif")
    page_source.should include("The Gap")
  end

  scenario "Find by suburb" do
    enter_text("Text_Locator__Suburb", "Alderley")
    click_button_with_image("search_button.gif")
    page_source.should include("Ashgrove")  
  end

  scenario "Find by extended trading hours" do
    checkbox(:id, "OpenExtendedTradingHoursSerivceId").click
    enter_text("Postcode_Locator__Postcode", "4061") 
    click_button_with_image("search_button.gif")
    page_source.should include("Queen St Mall")  
  end
end

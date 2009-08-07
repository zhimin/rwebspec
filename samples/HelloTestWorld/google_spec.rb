# This is a comment (ignored),  line starting with #
# Simple Spec shows using RWebUnit write easy-to-read automated test scripts (or specification)

require 'rwebspec'

spec "google search" do
  include RWebUnit::RSpecHelper

  before(:all) do
    open_browser "http://www.google.com"
  end

  before(:each) do
    visit "/"
  end

  after(:all) do
    close_browser
  end

  scenario "Page navigations" do
    enter_text("q", "iTest2")
    click_button("Google Search")
    click_link("iTest2 - Automated Testing Made Easy")
    page_title.should == "iTest2 - Automated Testing Made Easy"
    refresh
    click_link("Wiki")
    go_back
    go_forward
    page_source.should include("What makes iTest different?")
  end
  
end

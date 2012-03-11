# This is a comment (ignored),  line starting with #
# Simple Spec shows using RWebSpec write easy-to-read automated test scripts (or specification)
require 'rubygems'
require 'watir'
require 'rwebspec'

specification "google search" do
  include RWebSpec::RSpecHelper

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
    click_link("iTest2 - Watir IDE and more ...")
    page_title.should == "iTest2 - Watir IDE and more ..."
    refresh
    click_link("Features")
    go_back
    go_forward
    page_source.should include("Professional Edition adds ...")
  end
  
end

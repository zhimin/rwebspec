# This is a comment (ignored),  line starting with #
# Simple Spec shows using RWebSpec write easy-to-read automated test scripts (or specification)
require 'rubygems'
require 'watir'
require 'rwebspec'

include RWebSpec::RSpecHelper

open_browser "http://www.google.com", :firefox => true
visit "/"

enter_text("q", "iTest2")
click_button("Google Search")
click_link("iTest2 - Watir IDE and more ...")
page_title.should == "iTest2 - Watir IDE and more ..."
refresh
click_link("Features")
go_back
go_forward
page_source.should include("Professional Edition adds ...")
close_browser

# This is a comment (ignored),  line starting with #
# Simple Spec shows using RWebSpec write easy-to-read automated test scripts (or specification)

require 'rubygems'
require 'rwebspec'

RWebSpec.framework = "Selenium-WebDriver"

include RWebSpec::Core

open_browser :base_url => "http://testwisely.com/demo", :browser => :chrome
click_link("NetBank")
page_title.should == "NetBank"
select_option("account", "Cheque")
enter_text("amount", "123.54")
click_button("Transfer")
raise "No receipt generated" unless page_source.include?("Receipt No")
refresh
go_back
go_forward


# Equovalent RAw Selenium Tests
# driver = Selenium::WebDriver.for :firefox # or :ie or :chrome;
# browser.navigate.to "http://testwisely.com/demo"
# browser.find_element(:link_text, "NetBank").click
# Selenium::WebDriver::Support::Select.new(browser.find_element(:name, "account")).select_by(:text, "Cheque")
# browser.find_element(:id, "rcptAmount").send_keys("123.54")
# browser.find_element(:xpath,"//input[@value='Transfer']").click


# Equovalent Raw Watir Tests
# browser = Watir::Browser.start "http://testwisely.com/demo"
# browser.link(:text, "NetBank").click
# browser.select_list(:name, "account").select("Cheque")
# browser.text_field(:id, "rcptAmount").set("123.54")
# browser.button(:value,"Transfer").click 
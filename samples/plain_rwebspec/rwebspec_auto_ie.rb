# This is a comment (ignored),  line starting with #
# Simple Spec shows using RWebSpec write easy-to-read automated test scripts (or specification)

require 'rubygems'
require 'rwebspec'

# Not setting the framework, RWebSpec auto detects, using Watir for IE, Seleniumf or Others
# RWebSpec.framework = "Watir"

include RWebSpec::Core

open_browser :base_url => "http://testwisely.com/demo", :browser => :ie
click_link("NetBank")
page_title.should == "NetBank"
select_option("account", "Cheque")
enter_text("amount", "123.54")
click_button("Transfer")
raise "No receipt generated" unless page_source.include?("Receipt No")
refresh
go_back
go_forward

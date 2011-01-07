# This is a comment (ignored),  line starting with #
# Simple Spec shows using RWebSpec write easy-to-read automated test scripts (or specification)
require 'rubygems'
require 'firewatir'

ff=FireWatir::Firefox.new
#Open yahoo mail. 
ff.goto("http://mail.yahoo.com")

#Put your user name. 
ff.text_field(:name,"login").set("User_Name")

#Put your password.
ff.text_field(:name,"passwd").set("Password")

#Click Sign In button.
ff.button(:value,"Sign In").click

#Click Sign Out button.
ff.link(:text, "Sign Out").click

#Close the browser.
ff.close

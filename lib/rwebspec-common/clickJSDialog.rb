#
#  clickJSDialog.rb 
#
#
# This file contains the JS clicker when it runs as a separate process
require 'watir/winClicker'

button = "OK"
button = ARGV[0] unless ARGV[0] == nil
sleepTime = 0
sleepTime = ARGV[1] unless ARGV[1] == nil

clicker= WinClicker.new
result = clicker.clickJavaScriptDialog( button )
clicker = nil

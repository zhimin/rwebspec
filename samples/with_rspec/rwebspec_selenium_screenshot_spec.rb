require 'rwebspec'

describe "Task a screenshot of browser" do

  include RWebSpec::RSpecHelper  
  
  test "Open Chrome browser then take a screenshot to a specified file" do
    open_browser "http://testwisely.com/demo", :browser => :chrome
    click_link("NetBank")
    take_screenshot("./tmp_netbank.png")
    close_browser
  end


  test "Open Chrome browser then take a screenshot : default name under default folder" do
    open_browser "http://testwisely.com/demo", :browser => :chrome
    take_screenshot
    close_browser
  end


  test "Open Chrome browser then take a screenshot to system generate name under a folder" do
    open_browser "http://testwisely.com/demo", :browser => :chrome
    take_screenshot(nil, :to_dir => "/Users/zhimin/tmp")
    close_browser
  end

  test "Open Firefox browser then take a screenshot : default name under default folder" do
    open_browser "http://testwisely.com/demo", :browser => :firefox
    click_link("Survey")
    take_screenshot
    close_browser
  end

end

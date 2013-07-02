require 'rwebspec'

RWebSpec.framework = "Selenium-WebDriver"

describe "AJAX browser IE (selenium)" do

  include RWebSpec::RSpecHelper  
  
  before(:each) do
    open_browser :base_url => "http://testwisely.com/demo", :browser => :ie  
  end

  it "Money transfer (AJAX)" do
    click_link("NetBank")
    page_title.should == "NetBank"
    select_option("account", "Cheque")
    enter_text("amount", "123.54")
    click_button("Transfer")
    page_source.should include("Receipt No")
  end

end

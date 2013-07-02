require 'rwebspec'

RWebSpec.framework = "Selenium-WebDriver"

describe "AJAX browser Chrome (selenium)" do

  include RWebSpec::Core  
  include RWebSpec::Assert
  
  before(:each) do
    open_browser :base_url => "http://testwisely.com/demo", :browser => :chrome  
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

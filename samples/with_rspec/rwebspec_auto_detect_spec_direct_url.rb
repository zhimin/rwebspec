require 'rwebspec'

describe "AJAX browser (Watir, auto detect browser and underlying framework)" do

  include RWebSpec::RSpecHelper  
  
  before(:each) do
    open_browser "http://testwisely.com/demo"
  end

  it "Money transfer (AJAX)" do
    click_link("NetBank")
    page_title.should == "NetBank"
    select_option("account", "Cheque")
    enter_text("amount", "123.54")
    click_button("Transfer")
    page_source.should include("Receipt No")
    goto_page("/help")
  end

end

require 'rwebspec'

# This tests depends on external web site
spec "Execute Window Scripts" do
  include RWebSpec::RSpecHelper

  scenario "Upload file attachment" do
    open_browser "http://demos.telerik.com/aspnet-ajax/combobox/examples/functionality/filteringcombo/defaultcs.aspx"
    # browser.ie.execute_script "RadComboBox1.FindItemByText(\"Golf\").Select()"
    #browser.execute_script "window.Result = RadComboBox1.GetText()"
    browser.ie.execute_script "$find('RadComboBox1').showDropDown()"
    browser.ie.execute_script "window.Result = $find('RadComboBox1').get_dropDownVisible()"

    #assert_equal true, @ie.window.Result
    browser.ie.window.Result.should == true
  end

end

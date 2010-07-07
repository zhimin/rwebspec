require 'rwebspec'

# This tests depends on external web site
#
# http://blogs.telerik.com/testing/posts/08-11-07/testing_radcontrols_for_asp_net_ajax_with_watir_%E2%80%93_how_easy_it_is.aspx
#
specification "Execute Window Scripts" do
  include RWebSpec::RSpecHelper

  before(:all) do
    open_browser "http://demos.telerik.com"
    @ie = browser.ie
  end

  scenario "Upload file attachment" do
    @ie.goto("http://demos.telerik.com/aspnet-ajax/combobox/examples/functionality/filteringcombo/defaultcs.aspx")
    @ie.execute_script "$find('RadComboBox1').showDropDown()"
    @ie.execute_script "window.Result = $find('RadComboBox1').get_dropDownVisible()"
    @ie.window.Result.should == true
  end

  test "Open Menu" do
    @ie.goto"http://demos.telerik.com/aspnet/prometheus/Menu/Examples/Default/DefaultCS.aspx"
    @ie.execute_script "$find('RadMenu1').get_items().getItem(0).open()"
    @ie.execute_script "window.Result = $find('RadMenu1').get_openedItem().get_text()"
    @ie.window.Result.should == "File"
  end

  test "select"  do
    @ie.goto "http://demos.telerik.com/aspnet/prometheus/TreeView/Examples/Programming/XmlFile/DefaultCS.aspx"
    @ie.execute_script "$find('RadTreeView1').get_nodes().getNode(0).select()"
    @ie.execute_script "window.Result = $find('RadTreeView1').get_selectedNode().get_text()"
    @ie.window.Result.should == "Desktop"
  end
end

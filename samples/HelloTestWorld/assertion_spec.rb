require 'rwebspec'

begin
  FireWatir::Firefox.firefox_started = true
rescue => e
end

##
# This test suite demos the assertion you can do with rWebUnit or Watir
#
spec "Basic operations and Assertions" do
  include RWebUnit::RSpecHelper

  @@test_page = File.join(File.dirname(File.expand_path(__FILE__)), "test_page.html")
  
  before(:all) do
    open_browser("file://" + @@test_page)
  end

  after(:all) do
    close_browser if is_firefox? and is_windows?
  end

  scenario "Assert Text" do
    assert_title("For Testing iTest2")
    assert_text_present("iTest2/Watir Test Page")
    assert_text_not_present("iTest3/Watir Test Page")

    click_link("iTest2")
    click_link_with_id("link_itest2")
  end

  scenario "Assert (href) Link" do
    assert_link_present_with_text("iTest2 with Id")
    assert_link_not_present_with_text("iTest2 with id")
    assert_link_not_present_with_text("XX")
  end

  scenario "Assert Checkbox" do
    assert_checkbox_not_selected("checkbox1")
    check_checkbox("checkbox1")
    assert_checkbox_selected("checkbox1")
    uncheck_checkbox("checkbox1")
    assert_checkbox_not_selected("checkbox1")

    # Watir way
    checkbox(:id,"checkbox3").set
    checkbox(:id,"checkbox3").clear
  end

  scenario "Assert Radio Button" do
    assert_radio_option_present("os", "Linux")
    assert_radio_option_present("os","Apple")
    assert_radio_option_not_present("os","Windows")
    click_radio_option("os", "Linux")
    assert_radio_option_selected("os", "Linux")
  end

  scenario "Assert Button, Image Button" do
    assert_button_present("login-btn")
    assert_button_not_present("login-Btn")
    assert_button_present_with_text("Login")
    assert_button_not_present_with_text("login")

    click_button_with_id("login-btn")
    click_button("Login")
    click_button_with_image("search_button.gif")
    go_back
  end

  scenario "Assert Select List (ComboBox)" do
    assert_option_value_present("testing_tool", "Watir")
    assert_option_value_present("testing_tool", "iTest2")
    assert_option_present("testing_tool", "iTest2 display")
    select_option("testing_tool", "Watir")
    select_option("testing_tool", "iTest2 display")
    assert_option_equals("testing_tool", "iTest2 display")
    assert_option_value_equals("testing_tool", "iTest2")

    #Watir way
    select_list(:id, "methodology").set("Water way")
  end


  ##
  # add id to tags for making verification easier
  #  <label id="label_1">Your text to be checked</label>
  scenario "Asserty specific text using HTML Id" do 
    label_with_id("label_1").should == "First Label"
    label_with_id("label_2").should == "Second Label"
    span_with_id("span_1").should == "First Span"
    span_with_id("span_2").should == "Second Span"
    
    cell(:id, "cell_1_1").text.should == "A"
    cell_with_id("cell_1_1").should == "A"
    cell_with_id("cell_2_2").should == "b"
    
    #Watir way
    label(:id, "label_1").text.should == "First Label"
    cell(:id, "cell_1_1").text.should == "A"
  end
  
  # If you get failure (on IE), please make sure your IE security allow JavaScript
  
  # scenario "Ajax - show or hide text, assert visible?" do
  #   click_link("Show info")
  #   sleep 0.5
  #   assert_text_present("I like iTest2")
  #   click_link("Hide info")
  #   sleep 0.5
  # 
  #   #TODO doesn't work on Firefox
  #   assert !div(:id, "info").visible?
  #   click_link("Show info")
  #   sleep 0.5
  #   assert div(:id, "info").visible?
  # end
  
  scenario "Assert same control with same text" do 
    # by default, select first matching control
    link(:text, "Click Me").click
    assert div(:id, "for_link_1").visible?    
    link(:text => "Click Me", :index => 2).click
    assert div(:id, "for_link_2").visible?
  end
  
  #TODO date
  #TODO attach window
  #TODO frames
end

class HomePage < RWebSpec::AbstractWebPage

  def initialize(browser, text='')    
    super(browser)        
    title.should == "My Organized Info"
  end

end
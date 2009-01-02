
class HomePage < BasePublicPage

  def initialize(browser, text="")
    super(browser)
    title.should == "MySportsWorx"
  end

end
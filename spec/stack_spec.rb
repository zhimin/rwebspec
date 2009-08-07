$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebspec")

require File.dirname(__FILE__) + "/stack"

describe "Normal RSpec Syntax still works" do
  before(:each) do
    @stack = Stack.new
  end

  specify "should complain when sent #peek" do
    lambda { @stack.peek }.should raise_error(StackUnderflowError)
  end

  it "should complain when sent #pop" do
    lambda { @stack.pop }.should raise_error(StackUnderflowError)
  end
end

#END

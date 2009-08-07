require File.dirname(__FILE__) + "/stack"
$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebspec")
gem "rspec"
require File.join(File.dirname(__FILE__), "..", "lib/rspec_extensions.rb")

test_suite "Test suite syntax" do
  before(:each) do
    @stack = Stack.new
  end

  test "should complain when sent #peek" do
    lambda { @stack.peek }.should raise_error(StackUnderflowError)
  end

  it "should complain when sent #pop" do
    lambda { @stack.pop }.should raise_error(StackUnderflowError)
  end
end

specification "Specification syntax" do
  before(:each) do
    @stack = Stack.new
    (1..10).each { |i| @stack.push i }
    @last_item_added = 10
  end
  #ABC
  story 'should complain on #push' do
    lambda { @stack.push Object.new }.should raise_error(StackOverflowError)
  end
end
#END

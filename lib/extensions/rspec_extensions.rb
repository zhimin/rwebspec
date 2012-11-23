
module RSpec
  module Core
 		module DSL
	    alias_method :specification, :describe
    	alias_method :test_suite, :describe
		end
	end
end

module RSpec
  module Core
    class ExampleGroup

      define_example_method :scenario
      define_example_method :story
      define_example_method :test_case
      define_example_method :use_case
      define_example_method :test

      class << self
        alias_method :specification, :describe
        alias_method :test_suite, :describe
      end

    end
  end
end
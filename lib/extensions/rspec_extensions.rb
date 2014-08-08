
=begin

# Deprecated for RSpec 3

module RSpec
  module Core
 		module DSL
	    alias_method :specification, :describe
    	alias_method :test_suite, :describe
		end
	end
end

=end

module RSpec
  module Core
    class ExampleGroup

      class << self
        # the following might not be used
        alias_method :specification, :describe
        alias_method :test_suite, :describe
                
        alias_method :story, :it
        alias_method :test_case, :it
        alias_method :scenario, :it
        
      end

    end
  end
end
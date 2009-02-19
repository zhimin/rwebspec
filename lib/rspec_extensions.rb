module Spec
  module Extensions
    module Main

      alias :spec :describe
      alias :specification :describe
      alias :test_suite :describe
      alias :suite :describe

    end
  end
end

# For RSpec 1.1.12
module Spec
  module DSL
    module Main

      alias :spec :describe
      alias :specification :describe
      alias :test_suite :describe
      alias :suite :describe

    end
  end
end

# ZZ patches to RSpec 1.1.4
#  - add to_s method to example_group
module Spec
  module Example
    class ExampleGroup
      def to_s
        @_defined_description
      end
    end
  end
end

module Spec
  module Example
    module ExampleGroupMethods

      alias_method :scenario, :it
      alias_method :story, :it
      alias_method :test_case, :it
      alias_method :test, :it
    end
  end
end
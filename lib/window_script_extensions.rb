require 'rubygems'
require 'watir'

# Used for calling javacript of VBScript
# Applies to IE only
#
# Ref: http://msdn.microsoft.com/en-us/library/aa741364%28VS.85%29.aspx
#
module Watir
  class IE
    def execute_script(scriptCode)
      window.execScript(scriptCode)
    end

    def window
      ie.Document.parentWindow
    end
  end
end

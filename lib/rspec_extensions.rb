module Spec
  module Extensions
    module Main
    
      alias :spec :describe
      alias :specification :describe
          
    end
  end
end


module Spec
  module Example
    module ExampleGroupMethods
    
      alias_method :scenario, :it
      alias_method :story, :it
    end
  end
end


module Spec
  class Translator
  
    def translate_line(line)
      # Translate deprecated mock constraints
      line.gsub!(/:any_args/, 'any_args')
      line.gsub!(/:anything/, 'anything')
      line.gsub!(/:boolean/, 'boolean')
      line.gsub!(/:no_args/, 'no_args')
      line.gsub!(/:numeric/, 'an_instance_of(Numeric)')
      line.gsub!(/:string/, 'an_instance_of(String)')

      return line if line =~ /(should_not|should)_receive/
      
      line.gsub!(/(^\s*)context([\s*|\(]['|"|A-Z])/, '\1describe\2')
      line.gsub!(/(^\s*)spec([\s*|\(]['|"|A-Z])/, '\1describe\2') #new
      line.gsub!(/(^\s*)specification([\s*|\(]['|"|A-Z])/, '\1describe\2') #new
      line.gsub!(/(^\s*)specify([\s*|\(]['|"|A-Z])/, '\1it\2')
      line.gsub!(/(^\s*)scenario([\s*|\(]['|"|A-Z])/, '\1it\2')  #new
      line.gsub!(/(^\s*)story([\s*|\(]['|"|A-Z])/, '\1it\2')  #new
      line.gsub!(/(^\s*)context_setup(\s*[do|\{])/, '\1before(:all)\2')
      line.gsub!(/(^\s*)context_teardown(\s*[do|\{])/, '\1after(:all)\2')
      line.gsub!(/(^\s*)setup(\s*[do|\{])/, '\1before(:each)\2')
      line.gsub!(/(^\s*)teardown(\s*[do|\{])/, '\1after(:each)\2')
      
      if line =~ /(.*\.)(should_not|should)(?:_be)(?!_)(.*)/m
        pre = $1
        should = $2
        post = $3
        be_or_equal = post =~ /(<|>)/ ? "be" : "equal"
        
        return "#{pre}#{should} #{be_or_equal}#{post}"
      end
      
      if line =~ /(.*\.)(should_not|should)_(?!not)\s*(.*)/m
        pre = $1
        should = $2
        post = $3
        
        post.gsub!(/^raise/, 'raise_error')
        post.gsub!(/^throw/, 'throw_symbol')
        
        unless standard_matcher?(post)
          post = "be_#{post}"
        end
        
        # Add parenthesis
        post.gsub!(/^(\w+)\s+([\w|\.|\,|\(.*\)|\'|\"|\:|@| ]+)(\})/, '\1(\2)\3') # inside a block
        post.gsub!(/^(redirect_to)\s+(.*)/, '\1(\2)') # redirect_to, which often has http:
        post.gsub!(/^(\w+)\s+([\w|\.|\,|\(.*\)|\{.*\}|\'|\"|\:|@| ]+)/, '\1(\2)')
        post.gsub!(/(\s+\))/, ')')
        post.gsub!(/\)\}/, ') }')
        post.gsub!(/^(\w+)\s+(\/.*\/)/, '\1(\2)') #regexps
        line = "#{pre}#{should} #{post}"
      end

      line
    end
  end
end


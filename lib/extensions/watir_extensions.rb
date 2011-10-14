gem 'watir'
require 'fileutils'
require 'watir/container'
require 'watir/element_collections'
require 'watir/element'

module Watir
  # Base class for html elements.
  # This is not a class that users would normally access.
  class Element

    def method_missing(method_name, *args, &block)

      if ($TESTWISE_DIR || $TESTWISE_BROWSER) &&  method_name.to_s =~ /(.*)_no_wait/ && self.respond_to?($1)
        ruby_code = testwise_generate_ruby_code(self, $1, *args)
        testwise_click_no_wait(ruby_code)

      elsif method_name.to_s =~ /(.*)_no_wait/ && self.respond_to?($1)
        puts "[Watir] handle it"
        assert_exists
        assert_enabled
        highlight(:set)
        ruby_code = generate_ruby_code(self, $1, *args)
        system(spawned_no_wait_command(ruby_code))
        highlight(:clear)
      else
        super
      end

    end


    def testwise_generate_ruby_code(element, method_name, *args)
      element = "#{self.class}.new(#{@page_container.attach_command}, :unique_number, #{self.unique_number})"
      method = build_method(method_name, *args)
      watir_load_path = []
      watir_lib_path = nil
      $LOAD_PATH.each do |x|
        if x =~ /rautomation/ || x =~ /watir/
          watir_load_path << x
          if x =~ /\/gems\/watir-/
            watir_lib_path = x
          end
        end
      end
      watir_load_path = $LOAD_PATH
      ruby_code = "$:.unshift(#{watir_load_path.map {|p| "'#{p}'" }.join(").unshift(")});" <<
      "require '#{watir_lib_path}/watir/core';#{element}.#{method};"
      return ruby_code
    end

    # customiiation here
    #
    def testwise_click_no_wait(ruby_code)
      begin
        puts "[TestWise] I am handling it"
        assert_exists
        assert_enabled
        highlight(:set)
        current_path = File.expand_path(".")

        # not necessary
        # ruby_code.gsub("C:/Program Files/TestWise/vendor/bundle/ruby/1.8", "C:/rubyshell/ruby/lib/ruby/gems/1.8")

        # Trick 1: need to set RUBYOPT, otherwise might get -F error    
        ENV["RUBYOPT"] = "-rubygems"
        
        # Trick 2: need to wrap no-wait click operation in a thread
        Thread.new do
          system("ruby", "-e", ruby_code)
        end
        highlight(:clear)
      rescue RuntimeError => re
        puts re.backtrace

      rescue => e
        puts "Failed to click_no_wait: #{e.backtrace}"
        raise e
      end
    end

  end
end

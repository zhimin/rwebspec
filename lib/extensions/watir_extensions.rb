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
      puts "XXX => #{$TESTWISE_DIR}"
      if ($TESTWISE_DIR || TESTWISE_ENV) &&  method_name.to_s =~ /(.*)_no_wait/ && self.respond_to?($1)
        puts "[TestWise] handle it"
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
      
      ruby_code = "$:.unshift(#{watir_load_path.map {|p| "'#{p}'" }.join(").unshift(")});" <<
      "require '#{watir_lib_path}/watir/core';#{element}.#{method};"
      return ruby_code
    end

    # customiiation here
    #
    def testwise_click_no_wait(ruby_code)
      require 'systemu'
      begin
        puts "[TestWise] I am handling it"
        assert_exists
        assert_enabled
        highlight(:set)
        current_path = File.expand_path(".")
        FileUtils.chdir("C:\\")
        ruby_code.gsub!("C:/Program Files/TestWise/vendor/bundle/ruby/1.8", "C:/rubyshell/ruby/lib/ruby/gems/1.8")
        # puts ruby_code
        # system("dir %CD%")
        # system("c:/rubyshell/ruby/bin/ruby.exe RUBYOPT=\"\" -e #{ruby_code}")
        fio = File.open("C:\\tmp.rb", "w")
        fio.write(ruby_code)  
        fio.flush
        fio.close
      
        click_elem_cmd = %q(ruby -e #{ruby_code})
        status, stdout, stderr = systemu  click_elem_cmd
        puts [ status, stdout, stderr ]

        # systemu("c:/rubyshell/ruby/bin/ruby.exe -e #{ruby_code}", :env => {})        
        FileUtils.chdir(current_path)
        # puts "DEBUG: #{ruby_code}"
        highlight(:clear)
      rescue => e
        puts "Failed to click_no_wait: #{e.backtrace}"
        raise e
      end
    end


  end

end

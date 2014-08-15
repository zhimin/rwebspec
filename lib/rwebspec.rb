#***********************************************************
#* Copyright (c) 2006 - 2012, Zhimin Zhan.
#* Distributed open-source, see full license in MIT-LICENSE
#***********************************************************
require "rubygems"

gem "activesupport" #,  "~> 3.2.17"
require 'active_support'
require 'active_support/deprecation'

# Using own assert
# 
# if user want to use testing library such as MiniTest, add require in your own helper and tests
#
# gem "minitest" #, "~> 4.0" # ver 5 return errors
# require 'minitest/autorun'

# Load active_support, so that we can use 1.days.ago
begin
  require 'active_support/core_ext'
  require 'active_support/time'
rescue LoadError => no_as1_err
    puts "failed to load activesupport #{no_as1_err}"
end

require 'rspec'

=begin
# From RWebSpec 6 fully supports RSpec 3
#
# For non-rwebspec project, need to add to the help to avoid deprecation warning
if  ::RSpec::Version::STRING && ::RSpec::Version::STRING =~ /^3/
  RSpec.configure do |config|
    config.expect_with :rspec do |c|
      c.syntax = :should
    end
  end
end
=end

unless defined? RWEBSPEC_VERSION
  RWEBSPEC_VERSION = RWEBUNIT_VERSION = "6.0.2"
end

$testwise_polling_interval = 1 # seconds

$testwise_polling_timeout = 30 # seconds


if RUBY_PLATFORM =~ /mingw/
 $screenshot_supported = false
 begin
   require 'win32/screenshot'
   $screenshot_supported = true
 rescue LoadError => no_screen_library_error
 end  
end

begin
  require 'selenium-webdriver'
rescue LoadError => e
  $selenium_loaded = false
end


module RWebSpec
  class << self
    def version
      RWEBSPEC_VERSION
    end

    def framework
      @_framework ||= begin
        ENV["RWEBSPEC_FRAMEWORK"] 
        # ||= (RUBY_PLATFORM =~ /mingw/ ? "Watir" : "Selenium-WebDriver")
      end
      @_framework
    end

    def framework=(framework)
      old_framework = @_framework
      @_framework = ActiveSupport::StringInquirer.new(framework)
      if (old_framework != @_framework) then
        puts "[INFO] Switching framework to #{@_framework}"
        load_framework
      end
    end

    def load_watir
      # puts "Loading Watir"
      require 'watir'
      
      if RUBY_PLATFORM =~ /mingw/i
        require 'watir-classic'
      end
    
      load(File.dirname(__FILE__) + "/rwebspec-watir/web_browser.rb")
      load(File.dirname(__FILE__) + "/rwebspec-watir/driver.rb")
      require File.dirname(__FILE__) + "/extensions/watir_extensions"
      require File.dirname(__FILE__) + "/extensions/window_script_extensions"
    end

    def load_selenium
      require 'selenium-webdriver'
      # puts "Loading Selenium"
      load(File.dirname(__FILE__) + "/rwebspec-webdriver/web_browser.rb")
      load(File.dirname(__FILE__) + "/rwebspec-webdriver/driver.rb")
      require File.dirname(__FILE__) + "/extensions/webdriver_extensions"
    end

    def load_framework
      if @_framework.nil?
        framework
      end

      if RWebSpec.framework =~ /watir/i
        load_watir
        return
      end

      if RWebSpec.framework =~ /selenium/i
         load_selenium
         return
      end

      puts "[WARN] not framework loaded yet"
    end

  end
end

require File.dirname(__FILE__) + "/plugins/testwise_plugin.rb"

# Changed in v4.3, the framework is loaded when initliating or reuse browser
#RWebSpec.load_framework

# Extra full path to load libraries
require File.dirname(__FILE__) + "/rwebspec-common/using_pages"
require File.dirname(__FILE__) + "/rwebspec-common/core"
require File.dirname(__FILE__) + "/rwebspec-common/web_page"
require File.dirname(__FILE__) + "/rwebspec-common/assert"
require File.dirname(__FILE__) + "/rwebspec-common/context"
require File.dirname(__FILE__) + "/rwebspec-common/test_script.rb"
require File.dirname(__FILE__) + "/rwebspec-common/rspec_helper.rb"

require File.dirname(__FILE__) + "/rwebspec-common/load_test_helper"
require File.dirname(__FILE__) + "/rwebspec-common/matchers/contains_text"
require File.dirname(__FILE__) + "/extensions/rspec_extensions"


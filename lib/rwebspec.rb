#***********************************************************
#* Copyright (c) 2006 - 2012, Zhimin Zhan.
#* Distributed open-source, see full license in MIT-LICENSE
#***********************************************************
require "rubygems"

# Load active_support, so that we can use 1.days.ago
begin
  require 'active_support/basic_object'
  require 'active_support/duration'
	require 'active_support/core_ext'
rescue LoadError => no_as1_err
  # active_support 2.0 loaded error
end

require 'rspec'

unless defined? RWEBSPEC_VERSION
  RWEBSPEC_VERSION = RWEBUNIT_VERSION = "4.1.5"
end

$testwise_polling_interval = 1 # seconds

$testwise_polling_timeout = 30 # seconds


if RUBY_PLATFORM =~ /mswin/ or RUBY_PLATFORM =~ /mingw/
 $screenshot_supported = false
 begin
   require 'win32/screenshot'
   $screenshot_supported = true
 rescue LoadError => no_screen_library_error
 end  
end

module RWebSpec
  class << self
    def version
      RWEBSPEC_VERSION
    end

    def framework
      @_framework ||= begin
        ENV["RWEBSPEC_FRAMEWORK"] ||= (RUBY_PLATFORM =~ /mingw/ ? "Watir" : "Selenium-WebDriver")
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
      load(File.dirname(__FILE__) + "/rwebspec-watir/web_browser.rb")
      load(File.dirname(__FILE__) + "/rwebspec-watir/driver.rb")
      require File.dirname(__FILE__) + "/extensions/watir_extensions"
      require File.dirname(__FILE__) + "/extensions/window_script_extensions"
    end

    def load_selenium
      # puts "Loading Selenium"
      load(File.dirname(__FILE__) + "/rwebspec-webdriver/web_browser.rb")
      load(File.dirname(__FILE__) + "/rwebspec-webdriver/driver.rb")
      require File.dirname(__FILE__) + "/extensions/webdriver_extensions"
    end

    def load_framework
      if @_framework.nil?
        framework
      end
      RWebSpec.framework  == "Watir" ? load_watir : load_selenium
    end

  end
end

# Watir 3 API Changes, no Watir/Container
require File.dirname(__FILE__) + "/plugins/testwise_plugin.rb"

RWebSpec.load_framework

# Extra full path to load libraries
require File.dirname(__FILE__) + "/rwebspec-common/using_pages"
require File.dirname(__FILE__) + "/rwebspec-common/test_utils"
require File.dirname(__FILE__) + "/rwebspec-common/web_page"
require File.dirname(__FILE__) + "/rwebspec-common/assert"
require File.dirname(__FILE__) + "/rwebspec-common/test_script"
require File.dirname(__FILE__) + "/rwebspec-common/context"
require File.dirname(__FILE__) + "/rwebspec-common/rspec_helper"
require File.dirname(__FILE__) + "/rwebspec-common/load_test_helper"
require File.dirname(__FILE__) + "/rwebspec-common/matchers/contains_text"
require File.dirname(__FILE__) + "/extensions/rspec_extensions"


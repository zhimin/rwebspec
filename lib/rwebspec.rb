#***********************************************************
#* Copyright (c) 2006 - 2011, Zhimin Zhan.
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
  RWEBSPEC_VERSION = RWEBUNIT_VERSION = "3.1.0"
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


# Extra full path to load libraries
require File.dirname(__FILE__) + "/rwebspec/using_pages"
require File.dirname(__FILE__) + "/rwebspec/test_utils"
require File.dirname(__FILE__) + "/rwebspec/web_page"
require File.dirname(__FILE__) + "/rwebspec/assert"
require File.dirname(__FILE__) + "/rwebspec/web_browser"
require File.dirname(__FILE__) + "/rwebspec/driver"
require File.dirname(__FILE__) + "/rwebspec/test_script"
require File.dirname(__FILE__) + "/rwebspec/context"
require File.dirname(__FILE__) + "/rwebspec/rspec_helper"
require File.dirname(__FILE__) + "/rwebspec/load_test_helper"

require File.dirname(__FILE__) + "/rwebspec/matchers/contains_text"
require File.dirname(__FILE__) + "/extensions/rspec_extensions"

# Watir 3 API Changes, no Watir/Container
if RUBY_PLATFORM =~ /mswin/ or RUBY_PLATFORM =~ /mingw/
	require File.dirname(__FILE__) + "/extensions/watir_extensions"
  require File.dirname(__FILE__) + "/extensions/window_script_extensions.rb"
end

require File.dirname(__FILE__) + "/plugins/testwise_plugin.rb"


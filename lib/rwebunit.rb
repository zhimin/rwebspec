#***********************************************************
#* Copyright (c) 2006, Zhimin Zhan.
#* Distributed open-source, see full license in MIT-LICENSE
#***********************************************************

# Load active_support, so that we can use 1.days.ago
begin
  require 'active_support/basic_object'
  require 'active_support/duration'
rescue LoadError => no_as1_err
  # active_support 2.0 loaded error
end
require 'active_support/core_ext'
require 'spec'
require 'hpricot' # for parsing HTML

# Extra full path to load libraries
require File.dirname(__FILE__) + "/rwebunit/test_utils"
require File.dirname(__FILE__) + "/rwebunit/web_page"
require File.dirname(__FILE__) + "/rwebunit/assert"
#This cause some unit test loaded, to use it, load specifiically
#require File.dirname(__FILE__) + "/rwebunit/web_testcase"
require File.dirname(__FILE__) + "/rwebunit/itest_plugin"
require File.dirname(__FILE__) + "/rwebunit/web_browser"
require File.dirname(__FILE__) + "/rwebunit/driver"
require File.dirname(__FILE__) + "/rwebunit/context"
require File.dirname(__FILE__) + "/rwebunit/driver"
require File.dirname(__FILE__) + "/rwebunit/rspec_helper"
require File.dirname(__FILE__) + "/rspec_extensions"
require File.dirname(__FILE__) + "/watir_extensions"
require File.dirname(__FILE__) + "/rwebunit/matchers/contains_text"

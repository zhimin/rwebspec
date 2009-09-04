#***********************************************************
#* Copyright (c) 2006 - 2009, Zhimin Zhan.
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

RWEBSPEC_VERSION = RWEBUNIT_VERSION = "1.4.1.0"

# Extra full path to load libraries
require File.dirname(__FILE__) + "/rwebspec/using_pages"
require File.dirname(__FILE__) + "/rwebspec/test_utils"
require File.dirname(__FILE__) + "/rwebspec/web_page"
require File.dirname(__FILE__) + "/rwebspec/assert"
require File.dirname(__FILE__) + "/rwebspec/itest_plugin"
require File.dirname(__FILE__) + "/rwebspec/web_browser"
require File.dirname(__FILE__) + "/rwebspec/driver"
require File.dirname(__FILE__) + "/rwebspec/test_script"
require File.dirname(__FILE__) + "/rwebspec/context"
require File.dirname(__FILE__) + "/rwebspec/rspec_helper"
require File.dirname(__FILE__) + "/rwebspec/load_test_helper"
require File.dirname(__FILE__) + "/rspec_extensions"
require File.dirname(__FILE__) + "/watir_extensions"
require File.dirname(__FILE__) + "/rwebspec/matchers/contains_text"

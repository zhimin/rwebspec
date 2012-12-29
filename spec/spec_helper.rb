require 'rubygems'
require "rspec"
require 'uri'
require 'test/unit/assertions'

# require File.join(File.dirname(__FILE__), "..", "lib/extensions/rspec_extensions.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/driver.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/context.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/web_browser.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/web_page.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/assert.rb")
# require File.join(File.dirname(__FILE__), "..", "lib/extensions/watir_extensions.rb")

# $:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebspec")

require File.join(File.dirname(__FILE__), "..", "lib/rwebspec.rb")

RWebSpec.framework = "Selenium"
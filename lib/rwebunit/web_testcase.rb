#***********************************************************
#* Copyright (c) 2006, Zhimin Zhan.
#* Distributed open-source, see full license in MIT-LICENSE
#***********************************************************

require 'test/unit'
require File.join(File.dirname(__FILE__), 'assert')
require File.join(File.dirname(__FILE__), 'driver')

module RWebUnit

  class WebTestCase < Test::Unit::TestCase
    include RWebUnit::Driver
    include RWebUnit::Assert
    include RWebUnit::Utils

    attr_reader :web_tester

    def initialize(name=nil)
      super(name) if name
      @web_tester = WebTester.new
    end

    def default_test
      super unless (self.class == WebTestCase)
    end

    def open_browser(baseUrl, relativeUrl)
      test_context.base_url = baseUrl
      begin_at(relativeUrl)
    end
    alias open_ie open_browser

  end

end

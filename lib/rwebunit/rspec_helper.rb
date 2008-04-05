require 'uri'

# ZZ patches to RSpec 1.1.2
#  - add to_s method to example_group
module Spec
  module Example
    class ExampleGroup
      def to_s
        @_defined_description
      end
    end
  end
end

# example
#   should link_by_text(text, options).size > 0

module RWebUnit
  module RSpecHelper
    include RWebUnit::Driver
    include RWebUnit::Utils
    include RWebUnit::Assert

    def browser
      @web_tester
    end

    # open a browser, and set base_url via hash, but does not acually
    #
    # example:
    #   open_browser :base_url => http://localhost:8080
    def open_browser(base_url = nil, options = {})
      base_url ||= ENV['ITEST_PROJECT_BASE_URL']
      raise "base_url must be set" if base_url.nil?
      
      default_options = {:speed => "fast",
        :visible => true,
        :highlight_colour => 'yellow',
        :close_others => true,
        :start_new => false, 	# start a new browser always
        :go => true}

      options = default_options.merge options
      options[:firefox] = true if "Firefox" == ENV['ITEST_BROWSER']

      uri = URI.parse(base_url)
      uri_base = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      if options[:start_new] || @web_tester.nil?
        @web_tester = WebTester.new(uri_base, options)
      end

      if options[:go]
        (uri.path.length == 0) ?  begin_at("/") :  begin_at(uri.path)
      end
      return @web_tester
    end
    alias open_browser_with open_browser

    # --
    #  Content
    # --
    def page_title
      @web_tester.page_title
    end

    def page_source
      @web_tester.page_source
    end

    def table_source(table_id)
      elem = @@browser.document.getElementById(table_id)
      raise "The element '#{table_id}' is not a table or there are multple elements with same id" unless elem.name.uppercase == "TABLE"
      elem.innerHTML
    end
    alias table_source_by_id table_source

    def element_text(elem_id)
      @web_tester.element_value(elem_id)
    end
    alias element_text_by_id element_text

    #TODO: is it working?
    def element_source(elem_id)
      @web_tester.get_html_in_element(elem_id)
    end

    def element_by_id(elem_id)
      @web_tester.element_by_id(elem_id)
    end

    def button_by_id(button_id)
      button(:id, button_id)
    end

    def buttons_by_caption(text)
      button(:text, text)
    end
    alias buttons_by_text buttons_by_caption

    def link_by_id(link_id)
      link(:id, link_id)
    end

    # default options: exact => true
    def links_by_text(link_text, options = {})
      options.merge!({:exact=> true})
      matching_links = []
      links.each { |link|
        matching_links << link if (options[:exact] ? link.text == link_text :  link.text.include?(link_text))
      }
      return matching_links
    end
    alias links_with_text links_by_text

    def save_page(file_name = nil)
      @web_tester.save_page(file_name)
    end
    
    def save_content_to_file(content, file_name = nil)      
      file_name ||= Time.now.strftime("%Y%m%d%H%M%S") + ".html"
      puts "about to save page: #{File.expand_path(file_name)}"
      File.open(file_name, "w").puts content
    end

  end

end

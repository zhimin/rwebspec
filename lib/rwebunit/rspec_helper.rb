require 'uri'

# ZZ patches to RSpec 1.1.2 - 1.1.4
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

    # --
    #  Content
    # --

    def table_source(table_id)
      table(:id, table_id).innerHTML
      # elem = @web_browser.document.getElementById(table_id)
      # raise "The element '#{table_id}' is not a table or there are multple elements with same id" unless elem.name.uppercase == "TABLE"
      # elem.innerHTML
    end
    alias table_source_by_id table_source

    def element_text(elem_id)
      @web_browser.element_value(elem_id)
    end
    alias element_text_by_id element_text

    #TODO: is it working?
    def element_source(elem_id)
      @web_browser.get_html_in_element(elem_id)
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
      @web_browser.save_page(file_name)
    end
    
    def save_content_to_file(content, file_name = nil)      
      file_name ||= Time.now.strftime("%Y%m%d%H%M%S") + ".html"
      puts "about to save page: #{File.expand_path(file_name)}"
      File.open(file_name, "w").puts content
    end

    # When running 
    def debugging?
      $ITEST2_DEBUGGING && $ITEST2_RUNNING_AS == "test_case"
    end
    
    # RSpec Matchers
    #   
    # Example,
    #   a_number.should be_odd_number
    def be_odd_number
       simple_matcher("must be odd number") { |actual| actual && actual.to_id % 2 == 1}
    end
  
  end

end

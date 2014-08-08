
module RWebSpec
  module Assert
    
    # own assert method
    def assert test, msg = nil
      msg ||= "Failed assertion, no message given."
      # comment out self.assertions += 1 to counting assertions
      unless test then
        msg = msg.call if Proc === msg
        raise RWebSpec::Assertion, msg
      end
      true
    end
    
    def fail(message)
      perform_assertion { assert(false, message) }
    end
    
    def assert_not(condition, msg = "")
      perform_assertion { assert(!condition, msg) }
    end

    def assert_not_nil(actual, msg="")
      perform_assertion { assert(!actual.nil?, msg) }
    end

    def assert_title_equals(title)
      assert_equals(title, @web_browser.page_title)
    end

    alias assert_title assert_title_equals

    # Assert text present in page source (html)
    #   assert_text_in_page_source("<b>iTest2</b>  Cool") # <b>iTest2</b>  Cool
    def assert_text_in_page_source(text)
      perform_assertion { assert((@web_browser.page_source.include? text), 'expected html: ' + text + ' not found') }
    end

    # Assert text not present in page source (html)
    #   assert_text_not_in_page_source("<b>iTest2</b>  Cool") # <b>iTest2</b>  Cool
    def assert_text_not_in_page_source(text)
      perform_assertion { assert(!(@web_browser.page_source.include? text), 'expected html: ' + text + ' found') }
    end

    # Assert text present in page source (html)
    #   assert_text_present("iTest2 Cool") # <b>iTest2</b>  Cool
    def assert_text_present(text)
      perform_assertion { assert((@web_browser.text.include? text), 'expected text: ' + text + ' not found') }
    end

    # Assert text not present in page source (html)
    #   assert_text_not_present("iTest2 Cool") # <b>iTest2</b>  Cool
    def assert_text_not_present(text)
      perform_assertion { assert(!(@web_browser.text.include? text), 'expected text: ' + text + ' found') }
    end


    ##
    # Link

    # Assert a link with specified text (exact match) in the page
    #
    #  <a href="">Click Me</a>
    #  assert_link_present_with_exact("Click Me") => true
    #  assert_link_present_with_exact("Click") => false
    #
    def assert_link_present_with_exact(link_text)
      @web_browser.links.each { |link|
        return if link_text == link.text
      }
      fail( "can't find the link with text: #{link_text}")
    end

    def assert_link_not_present_with_exact(link_text)
      @web_browser.links.each { |link|
        perform_assertion { assert(link_text != link.text, "unexpected link (exact): #{link_text} found") }
      }
    end

    # Assert a link containing specified text in the page
    #  
    #  <a href="">Click Me</a>
    #  assert_link_present_with_text("Click ") # => 
    #
    def assert_link_present_with_text(link_text)
			
      @web_browser.links.each { |link|
        return if link.text.include?(link_text)
      }
      fail( "can't find the link containing text: #{link_text}")
  
  	end

    def assert_link_not_present_with_text(link_text)
      @web_browser.links.each { |link|
        perform_assertion { assert(!link.text.include?(link_text), "unexpected link containing: #{link_text} found") }
      }
    end

		def is_selenium_element?(elem)
			elem.class.name =~ /Selenium/
		end

		def element_name(elem)
			elem.class.name =~ /Selenium/ ? elem['name'] : elem.name 			
		end

		def element_value(elem)
			elem.class.name =~ /Selenium/ ? elem['value'] : elem.value 			
		end

    ##
    # Checkbox
    def assert_checkbox_not_selected(checkbox_name)
      @web_browser.checkboxes.each { |checkbox|
				the_element_name = element_name(checkbox)
        if (the_element_name == checkbox_name) then		
	 				if is_selenium_element?(checkbox)
          	perform_assertion {  assert(!checkbox.selected?, "Checkbox #{checkbox_name} is checked unexpectly") }			
					else
          	perform_assertion {  assert(!checkbox.set?, "Checkbox #{checkbox_name} is checked unexpectly") }
					end
        end
      }
    end
    alias assert_checkbox_not_checked assert_checkbox_not_selected

    def assert_checkbox_selected(checkbox_name)
      @web_browser.checkboxes.each { |checkbox|
				the_element_name = element_name(checkbox)
        if (the_element_name == checkbox_name) then
					if is_selenium_element?(checkbox)	 	
          	perform_assertion { assert(checkbox.selected?, "Checkbox #{checkbox_name} not checked") }
					else
          	perform_assertion { assert(checkbox.set?, "Checkbox #{checkbox_name} not checked") }					
					end
        end
      }
    end

    alias assert_checkbox_checked assert_checkbox_selected

    ##
    # select
    def assert_option_value_not_present(select_name, option_value)
      @web_browser.select_lists.each { |select|
        the_element_name = element_name(select)
        next unless the_element_name == select_name
        
        if RWebSpec.framework =~ /watir/i        
          select.options.each do |option| # items in the list
            perform_assertion {  assert(!(option.value == option_value), "unexpected select option: #{option_value} for #{select_name} found") }
          end
        else
          select.find_elements(:tag_name => "option" ).each do |option|
    	      fail("unexpected option value: #{option_label} found") if option.value == option_value
    			end          
        end
      }
    end

    alias assert_select_value_not_present assert_option_value_not_present


    def assert_option_not_present(select_name, option_label)
      @web_browser.select_lists.each { |select|
				the_element_name = element_name(select)
        next unless the_element_name == select_name
        
        if RWebSpec.framework =~ /watir/i
          select.options.each do |option| # items in the list
            perform_assertion {  assert(!(option.text == option_label), "unexpected select option: #{option_label} for #{select_name} found") }
          end
        else
          select.find_elements(:tag_name => "option" ).each do |option|
    	      fail("unexpected option label: #{option_label} found") if option.text == option_label
    			end
        end
        
      }
    end

    alias assert_select_label_not_present assert_option_not_present

    def assert_option_value_present(select_name, option_value)
      @web_browser.select_lists.each { |select|
				the_element_name = element_name(select)
        next unless the_element_name  == select_name

				if RWebSpec.framework == "Watir"
	        select.options.each do |option| # items in the list
	          return if option.value == option_value
	        end					
				else					
					select.find_elements(:tag_name => "option" ).each do |option|
						return if element_value(option) == option_value
					end
				end
				
      }
      fail("can't find the combo box with value: #{option_value}")
    end

    alias assert_select_value_present assert_option_value_present
    alias assert_menu_value_present assert_option_value_present

    def assert_option_present(select_name, option_label)
      @web_browser.select_lists.each { |select|
				the_element_name = element_name(select)
        next unless the_element_name == select_name

				if RWebSpec.framework == "Watir"
	        select.options.each do |option| # items in the list
	          return if option.text == option_label
	        end
				else
					select.find_elements(:tag_name => "option" ).each do |option|
	          return if option.text == option_label
					end			
				end

      }
      fail("can't find the combo box: #{select_name} with value: #{option_label}")
    end

    alias assert_select_label_present assert_option_present
    alias assert_menu_label_present assert_option_present

    def assert_option_equals(select_name, option_label)
      @web_browser.select_lists.each { |select|
				the_element_name = element_name(select)
        next unless the_element_name == select_name

				if RWebSpec.framework == "Watir"

	        select.options.each do |option| # items in the list
	          if (option.text == option_label) then
	            perform_assertion { assert_equal(select.value, option.value, "Select #{select_name}'s value is not equal to expected option label: '#{option_label}'") }
	          end
	        end
	
				else
					select.find_elements(:tag_name => "option" ).each do |option|
		        if (option.text == option_label) then
							assert option.selected?
						end
					end
					
				end
      }
    end

    alias assert_select_label assert_option_equals
    alias assert_menu_label assert_option_equals

    def assert_option_value_equals(select_name, option_value)
      @web_browser.select_lists.each { |select|
				the_element_name = element_name(select)
        next unless the_element_name == select_name

				if RWebSpec.framework == "Watir"
	        perform_assertion {  assert_equal(select.value, option_value, "Select #{select_name}'s value is not equal to expected: '#{option_value}'") }
				else
	        perform_assertion {  assert_equal(element_value(select), option_value, "Select #{select_name}'s value is not equal to expected: '#{option_value}'") }					
				end
      }
    end

    alias assert_select_value assert_option_value_equals
    alias assert_menu_value assert_option_value_equals

    ##
    # radio

    # radio_group is the name field, radio options 'value' field
    def assert_radio_option_not_present(radio_group, radio_option)
      @web_browser.radios.each { |radio|
				the_element_name = element_name(radio)					
        if (the_element_name == radio_group) then
          perform_assertion {  assert(!(radio_option == element_value(radio) ), "unexpected radio option: " + radio_option  + " found") }
        end
      }
    end

    def assert_radio_option_present(radio_group, radio_option)
      @web_browser.radios.each { |radio|
				the_element_name = element_name(radio)				
        return if (the_element_name == radio_group) and (radio_option == element_value(radio) )
      }
      fail("can't find the radio option : '#{radio_option}'")
    end

    def assert_radio_option_selected(radio_group, radio_option)
      @web_browser.radios.each { |radio|
				the_element_name = element_name(radio)					
        if (the_element_name == radio_group and radio_option == element_value(radio) ) then
					if is_selenium_element?(radio)
          	perform_assertion { assert(radio.selected?, "Radio button #{radio_group}-[#{radio_option}] not checked") }
					else
          	perform_assertion { assert(radio.set?, "Radio button #{radio_group}-[#{radio_option}] not checked") }					
					end  
      	end
      }
    end

    alias assert_radio_button_checked assert_radio_option_selected
    alias assert_radio_option_checked assert_radio_option_selected

    def assert_radio_option_not_selected(radio_group, radio_option)
      @web_browser.radios.each { |radio|
				the_element_name = element_name(radio)						
        if (the_element_name == radio_group and radio_option == element_value(radio) ) then	
					if is_selenium_element?(radio)
          	perform_assertion {  assert(!radio.selected?, "Radio button #{radio_group}-[#{radio_option}] checked unexpected") }
					else
          	perform_assertion {  assert(!radio.set?, "Radio button #{radio_group}-[#{radio_option}] checked unexpected") }
					end
        end
      }
    end

    alias assert_radio_button_not_checked assert_radio_option_not_selected
    alias assert_radio_option_not_checked assert_radio_option_not_selected

    ##
    # Button
    def assert_button_not_present(button_id)
      @web_browser.buttons.each { |button|
				the_button_id = RWebSpec.framework == "Watir" ? button.id : button["id"]	
        perform_assertion { assert(the_button_id != button_id, "unexpected button id: #{button_id} found") }
      }
    end

    def assert_button_not_present_with_text(text)
      @web_browser.buttons.each { |button|
        perform_assertion { assert(element_value(button) != text, "unexpected button id: #{text} found") }
      }
    end

    def assert_button_present(button_id)
      @web_browser.buttons.each { |button|
				the_button_id = RWebSpec.framework == "Watir" ? button.id : button["id"]
        return if button_id == the_button_id
      }
      fail("can't find the button with id: #{button_id}")
    end

    def assert_button_present_with_text(button_text)
      @web_browser.buttons.each { |button|			
        return if button_text == element_value(button)
      }
      fail("can't find the button with text: #{button_text}")
    end


    def assert_equals(expected, actual, msg=nil)
      perform_assertion { assert(expected == actual, (msg.nil?) ? "Expected: #{expected} diff from actual: #{actual}" : msg) }
    end


    # Check a HTML element exists or not
    # Example:
    #  assert_exists("label", "receipt_date")
    #  assert_exists(:span, :receipt_date)
    def assert_exists(tag, element_id)
			if RWebSpec.framework == "Watir"
      	perform_assertion { assert(eval("#{tag}(:id, '#{element_id.to_s}').exists?"), "Element '#{tag}' with id: '#{element_id}' not found") }		
			else
				perform_assertion { assert( @web_browser.driver.find_element(:tag_name => tag, :id => element_id))}
			end
		
    end

    alias assert_exists? assert_exists
    alias assert_element_exists assert_exists

    def assert_not_exists(tag, element_id)
      if RWebSpec.framework == "Watir"			
        perform_assertion {  assert_not(eval("#{tag}(:id, '#{element_id.to_s}').exists?"), "Unexpected element'#{tag}' + with id: '#{element_id}' found")}
      else
        perform_assertion { 
           begin
             @web_browser.driver.find_element(:tag_name => tag, :id => element_id)
             fail("the element #{tag}##{element_id} found")
           rescue =>e  
           end
        }	
      end
    end

    alias assert_not_exists? assert_not_exists
    alias assert_element_not_exists? assert_not_exists


    # Assert tag with element id is visible?, eg. 
    #   assert_visible(:div, "public_notice")
    #   assert_visible(:span, "public_span")
    def assert_visible(tag, element_id)
			if RWebSpec.framework =~ /selenium/i
      	perform_assertion { assert(eval("#{tag}(:id, '#{element_id.to_s}').displayed?"), "Element '#{tag}' with id: '#{element_id}' not visible") }
			else
			  perform_assertion { assert(eval("#{tag}(:id, '#{element_id.to_s}').visible?"), "Element '#{tag}' with id: '#{element_id}' not visible") }
			end
    end

    # Assert tag with element id is hidden?, example 
    #   assert_hidden(:div, "secret")
    #   assert_hidden(:span, "secret_span")
    def assert_hidden(tag, element_id)
			if RWebSpec.framework =~ /selenium/i
      	perform_assertion { assert(!eval("#{tag}(:id, '#{element_id.to_s}').displayed?"), "Element '#{tag}' with id: '#{element_id}' is visible") }
			else
      	perform_assertion { assert(!eval("#{tag}(:id, '#{element_id.to_s}').visible?"), "Element '#{tag}' with id: '#{element_id}' is visible") }
			end
    end

    alias assert_not_visible assert_hidden


    # Assert given text appear inside a table (inside <table> tag like below) 
    #
    # <table id="t1">
    #
    # <tbody>
    #   <tr id="row_1">
    #     <td id="cell_1_1">A</td>
    #     <td id="cell_1_2">B</td>
    #   </tr>
    #   <tr id="row_2">
    #     <td id="cell_2_1">a</td>
    #     <td id="cell_2_2">b</td>
    #   </tr>
    # </tbody>
    #
    # </table>
    #
    # The plain text view of above table
    #  A B a b
    # 
    # Examples
    #  assert_text_present_in_table("t1", ">A<")  # => true
    #  assert_text_present_in_table("t1", ">A<", :just_plain_text => true)  # => false        
    def assert_text_present_in_table(table_id, text, options = {})
      options[:just_plain_text] ||= false
      perform_assertion { assert(the_table_source(table_id, options).include?(text), "the text #{text} not found in table #{table_id}") }
    end

    alias assert_text_in_table assert_text_present_in_table

    def assert_text_not_present_in_table(table_id, text, options = {})
      options[:just_plain_text] ||= false
      perform_assertion { assert_not(the_table_source(table_id, options).include?(text), "the text #{text} not found in table #{table_id}") }
    end

    alias assert_text_not_in_table assert_text_not_present_in_table

    # Assert a text field (with given name) has the value
    #
    # <input id="tid" name="text1" value="text already there" type="text">
    # 
    # assert_text_field_value("text1", "text already there") => true
    #
    def assert_text_field_value(textfield_name, text)
			if RWebSpec.framework == "Watir"				
      	perform_assertion { assert_equal(text, text_field(:name, textfield_name).value) }
			else
				the_element = @web_browser.driver.find_element(:name, textfield_name)
      	perform_assertion { assert_equal(text, element_value(the_element)) }
			end			
    end


    #-- Not tested
    # -----

    def assert_text_in_element(element_id, text)
      elem = element_by_id(element_id)
      if RWebSpec.framework == "Watir"							
        assert_not_nil(elem.innerText, "element #{element_id} has no text")
        perform_assertion { assert(elem.innerText.include?(text), "the text #{text} not found in element #{element_id}") }
      else
        perform_assertion { 
          # this works in text field
          assert(element_value(elem).include?(text), "the text #{text} not found in element #{element_id}")
          # TODO
        }
      end
    
    end

    # Use 
    #

    #TODO for drag-n-drop, check the postion in list
    #    def assert_position_in_list(list_element_id)
    #      raise "not implemented"
    #    end

    private
    def the_table_source(table_id, options)
      elem_table = RWebSpec.framework == "Watir" ? table(:id, table_id.to_s) : @web_browser.driver.find_element(:id => table_id)
      elem_table_text = elem_table.text
      elem_table_html = RWebSpec.framework == "Watir" ?  elem_table.html : elem_table["innerHTML"];
      table_source = options[:just_plain_text] ? elem_table_text : elem_table_html
    end


    def perform_assertion(&block)
      begin
        yield
      rescue StandardError => e
        # puts "[DEBUG] Assertion error: #{e}"
        take_screenshot if $take_screenshot
        raise e
      rescue MiniTest::Assertion => e2
        take_screenshot if $take_screenshot
        raise e2
      end
    end

  end
end

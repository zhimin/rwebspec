require 'test/unit/assertions'

module RWebSpec
  module Assert

    include Test::Unit::Assertions
    
    def assert_not(condition, msg = "")
      assert(!condition, msg)
    end
    
    def assert_nil(actual, msg="")
      assert(actual.nil?, msg)
    end

    def assert_not_nil(actual, msg="")
      assert(!actual.nil?, msg)
    end

    def fail(message)
      assert(false, message)
    end

    # assertions
    def assert_title_equals(title)
      assert_equals(title, @web_browser.page_title)
    end
    alias assert_title assert_title_equals

    # Assert text present in page source (html)
    #   assert_text_present("<h1>iTest2</h1>")
    def assert_text_present(text)
      assert((@web_browser.page_source.include? text), 'expected text: ' + text + ' not found')
    end

    # Assert text not present in page source (html)
    #   assert_text_not_present("<h1>iTest2</h1>")
    def assert_text_not_present(text)
      assert(!(@web_browser.page_source.include? text), 'expected text: ' + text + ' found')
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
        assert(link_text != link.text, "unexpected link (exact): #{link_text} found")
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
        assert(!link.text.include?(link_text), "unexpected link containing: #{link_text} found")
      }
    end


    ##
    # Checkbox
    def assert_checkbox_not_selected(checkbox_name)
      @web_browser.checkboxes.each { |checkbox|
        if (checkbox.name == checkbox_name) then
          assert(!checkbox.isSet?, "Checkbox #{checkbox_name} is checked unexpectly")
        end
      }
    end
	alias assert_checkbox_not_checked assert_checkbox_not_selected

    def assert_checkbox_selected(checkbox_name)
      @web_browser.checkboxes.each { |checkbox|
        if (checkbox.name == checkbox_name) then
          assert(checkbox.isSet?, "Checkbox #{checkbox_name} not checked")
        end
      }
    end
	alias assert_checkbox_checked assert_checkbox_selected

    ##
    # select
    def assert_option_value_not_present(select_name, option_value)
      @web_browser.select_lists.each { |select|
        continue unless select.name == select_name
        select.o.each do |option| # items in the list
          assert(!(option.value == option_value), "unexpected select option: #{option_value} for #{select_name} found")
        end
      }
    end
    alias assert_select_value_not_present assert_option_value_not_present

    def assert_option_not_present(select_name, option_label)
      @web_browser.select_lists.each { |select|
        next unless select.name == select_name
        select.o.each do |option| # items in the list
          assert(!(option.text == option_label), "unexpected select option: #{option_label} for #{select_name} found")
        end
      }
    end
    alias assert_select_label_not_present assert_option_not_present

    def assert_option_value_present(select_name, option_value)
      @web_browser.select_lists.each { |select|
        next unless select.name == select_name
        select.o.each do |option| # items in the list
          return if option.value == option_value
        end
      }
      assert(false, "can't find the combob box with value: #{option_value}")
    end
    alias assert_select_value_present assert_option_value_present
    alias assert_menu_value_present assert_option_value_present

    def assert_option_present(select_name, option_label)
      @web_browser.select_lists.each { |select|
        next unless select.name == select_name
        select.o.each do |option| # items in the list
          return if option.text == option_label
        end
      }
      assert(false, "can't find the combob box: #{select_name} with value: #{option_label}")
    end
    alias assert_select_label_present assert_option_present
    alias assert_menu_label_present assert_option_present

    def assert_option_equals(select_name, option_label)
      @web_browser.select_lists.each { |select|
        next unless select.name == select_name
        select.o.each do |option| # items in the list
          if (option.text == option_label) then
            assert_equal(select.value, option.value, "Select #{select_name}'s value is not equal to expected option label: '#{option_label}'")
          end
        end
      }
    end
    alias assert_select_label assert_option_equals
    alias assert_menu_label assert_option_equals

    def assert_option_value_equals(select_name, option_value)
      @web_browser.select_lists.each { |select|
        next unless select.name == select_name
        assert_equal(select.value, option_value, "Select #{select_name}'s value is not equal to expected: '#{option_value}'")
      }
    end
    alias assert_select_value assert_option_value_equals
    alias assert_menu_value assert_option_value_equals
    
    ##
    # radio

    # radio_group is the name field, radio options 'value' field
    def assert_radio_option_not_present(radio_group, radio_option)
      @web_browser.radios.each { |radio|
        if (radio.name == radio_group) then
          assert(!(radio_option == radio.value), "unexpected radio option: " + radio_option  + " found")
        end
      }
    end
	
    def assert_radio_option_present(radio_group, radio_option)
      @web_browser.radios.each { |radio|
        return if (radio.name == radio_group) and (radio_option == radio.value)
      }
      fail("can't find the radio option : '#{radio_option}'")
    end

    def assert_radio_option_selected(radio_group, radio_option)
      @web_browser.radios.each { |radio|
        if (radio.name == radio_group and radio_option == radio.value) then
          assert(radio.isSet?, "Radio button #{radio_group}-[#{radio_option}] not checked")
        end
      }
    end
	alias assert_radio_button_checked assert_radio_option_selected
	alias assert_radio_option_checked assert_radio_option_selected
	
    def assert_radio_option_not_selected(radio_group, radio_option)
      @web_browser.radios.each { |radio|
        if (radio.name == radio_group and radio_option == radio.value) then
          assert(!radio.isSet?, "Radio button #{radio_group}-[#{radio_option}] checked unexpected")
        end
      }
    end
    alias assert_radio_button_not_checked assert_radio_option_not_selected
    alias assert_radio_option_not_checked assert_radio_option_not_selected
	
    ##
    # Button
    def assert_button_not_present(button_id)
      @web_browser.buttons.each { |button|
        assert(button.id != button_id, "unexpected button id: #{button_id} found")
      }
    end

    def assert_button_not_present_with_text(text)
      @web_browser.buttons.each { |button|
        assert(button.value != text, "unexpected button id: #{text} found")
      }
    end

    def assert_button_present(button_id)
      @web_browser.buttons.each { |button|
        return if button_id == button.id
      }
      assert(false, "can't find the button with id: #{button_id}")
    end

    def assert_button_present_with_text(button_text)
      @web_browser.buttons.each { |button|
        return if button_text == button.value
      }
      assert(false, "can't find the button with text: #{button_text}")
    end


    def assert_equals(expected, actual, msg=nil)
      assert(expected == actual, (msg.nil?) ? "Expected: #{expected} diff from actual: #{actual}" : msg)
    end



    # Check a HTML element exists or not
    # Example:
    #  assert_exists("label", "receipt_date")
    #  assert_exists(:span, :receipt_date)
    def assert_exists(tag, element_id) {}
      begin
        assert eval("#{tag}(:id, '#{element_id.to_s}').exists?")
      rescue => e
        raise "Element '#{tag}' with id: '#{element_id}' not found, #{e}"
      end
    end
    alias assert_exists? assert_exists
    alias assert_element_exists assert_exists

    def assert_not_exists(tag, element_id) {}
      begin
        assert_not eval("#{tag}(:id, '#{element_id.to_s}').exists?")
        raise "Unexpected element'#{tag}' + with id: '#{element_id}' found"
      rescue => e
      end
    end
    alias assert_not_exists? assert_not_exists
    alias assert_element_not_exists? assert_not_exists


    # Assert tag with element id is visible?, eg. 
    #   assert_visible(:div, "public_notice")
    #   assert_visible(:span, "public_span")
    def assert_visible(tag, element_id)
      begin
        assert(eval("#{tag}(:id, '#{element_id.to_s}').visible?"))
      rescue => e
        raise "Element '#{tag}' with id: '#{element_id}' not visible, #{e}"
      end
    end

    # Assert tag with element id is hidden?, example 
    #   assert_hidden(:div, "secret")
    #   assert_hidden(:span, "secret_span")
    def assert_hidden(tag, element_id)
      begin
        assert(!eval("#{tag}(:id, '#{element_id.to_s}').visible?"))
      rescue => e
        raise "Element '#{tag}' with id: '#{element_id}' is visible, #{e}"
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
    def assert_text_present_in_table(table_id, text, options = { :just_plain_text => false })
      assert(table_source(table_id, options).include?(text),  "the text #{text} not found in table #{table_id}")
    end
    alias assert_text_in_table assert_text_present_in_table

    def assert_text_not_present_in_table(table_id, text, options = { :just_plain_text => false })
      assert_not(table_source(table_id, options).include?(text),  "the text #{text} not found in table #{table_id}")
    end
    alias assert_text_not_in_table assert_text_not_present_in_table

    # Assert a text field (with given name) has the value
    #
    # <input id="tid" name="text1" value="text already there" type="text">
    # 
    # assert_text_field_value("text1", "text already there") => true
    #
    def assert_text_field_value(textfield_name, text)
      assert_equal(text, text_field(:name, textfield_name).value)
    end

    
    #-- Not tested
    # -----
    
    def assert_text_in_element(element_id, text)
      elem = element_by_id(element_id)
      assert_not_nil(elem.innerText, "element #{element_id} has no text")
      assert(elem.innerText.include?(text), "the text #{text} not found in element #{element_id}")
    end

    # Use 
    #

    #TODO for drag-n-drop, check the postion in list
    #    def assert_position_in_list(list_element_id)
    #      raise "not implemented"
    #    end
    
    private
    def table_source(table_id, options)
   	  elem_table = table(:id, table_id.to_s)
      elem_table_text = elem_table.text 
      elem_table_html = is_firefox? ? elem_table.innerHTML : elem_table.html
      table_source = options[:just_plain_text] ? elem_table_text : elem_table_html
    end
    
  end
end

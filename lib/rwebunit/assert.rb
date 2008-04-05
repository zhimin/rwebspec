require 'runit/assert'

module RWebUnit
  module Assert

    include RUNIT::Assert

    #TODO for drag-n-drop, check the postion in list
    #    def assert_position_in_list(list_element_id)
    #      raise "not implemented"
    #    end

    ##
    # text
    def assert_text_present(text)
      assert((@web_tester.page_source.include? text), 'expected text: ' + text + ' not found')
    end

    def assert_text_not_present(text)
      assert(!(@web_tester.page_source.include? text), 'expected text: ' + text + ' found')
    end

    def assert_text_in_table(tableId, text)
      elem = element_by_id(tableId)
      assert_not_nil(elem, "tableId #{tableId} not exists")
      assert_equal(elem.tagName.upcase, "TABLE")
      puts elem.innerHTML if $DEBUG
      assert(elem.innerHTML.include?(text), "the text #{text} not found in table #{tableId}")
    end

    def assert_text_not_in_table(tableId, text)
      elem = element_by_id(tableId)
      assert_equal(elem.tagName.upcase, "TABLE")
      assert_not_nil(elem, "tableId #{tableId} not exists")            
      assert(!elem.innerHTML.include?(text), "unexpected text #{text} found in table #{tableId}")
    end

    def assert_element_present(elementID)
      assert_not_nil(element_by_id(elementID), "element with id #{elementID} not found")
    end

    def assert_element_not_present(elementID)
      assert_nil(element_by_id(elementID), "unexpected element with id #{elementID} found")
    end

    def assert_text_in_element(elementID, text)
      elem = element_by_id(elementID)
      assert_not_nil(elem.innerText, "element #{elementID} has no text")
      assert(elem.innerText.include?(text), "the text #{text} not found in element #{elementID}")
    end

    ##
    # Checkbox
    def assert_checkbox_not_selected(checkBoxName)
      @web_tester.checkboxes.each { |checkbox|
        if (checkbox.name == checkBoxName) then
          assert(!checkbox.isSet?, "Checkbox #{checkBoxName} checked unexpected")
        end
      }
    end

    def assert_checkbox_selected(checkBoxName)
      @web_tester.checkboxes.each { |checkbox|
        if (checkbox.name == checkBoxName) then
          assert(checkbox.isSet?, "Checkbox #{checkBoxName} not checked")
        end
      }
    end

    ##
    # select
    def assert_option_value_not_present(selectName, optionValue)
      @web_tester.select_lists.each { |select|
        continue unless select.name == selectName
        select.o.each do |option| # items in the list
          assert(!(option.value == optionValue), "unexpected select option: #{optionValue} for #{selectName} found")
        end
      }
    end

    def assert_option_not_present(selectName, optionLabel)
      @web_tester.select_lists.each { |select|
        next unless select.name == selectName
        select.o.each do |option| # items in the list
          assert(!(option.text == optionLabel), "unexpected select option: #{optionLabel} for #{selectName} found")
        end
      }
    end

    def assert_option_value_present(selectName, optionValue)
      @web_tester.select_lists.each { |select|
        next unless select.name == selectName
        select.o.each do |option| # items in the list
          return if option.value == optionValue
        end
      }
      assert(false, "can't find the combob box with value: #{optionValue}")
    end

    def assert_option_present(selectName, optionLabel)
      @web_tester.select_lists.each { |select|
        next unless select.name == selectName
        select.o.each do |option| # items in the list
          return if option.text == optionLabel
        end
      }
      assert(false, "can't find the combob box: #{selectName} with value: #{optionLabel}")
    end

    def assert_option_equals(selectName, optionLabel)
      @web_tester.select_lists.each { |select|
        next unless select.name == selectName
        select.o.each do |option| # items in the list
          if (option.text == optionLabel) then
            assert_equal(select.value, option.value, "Select #{selectName}'s value is not equal to expected option label: '#{optionLabel}'")
          end
        end
      }
    end

    def assert_option_value_equals(selectName, optionValue)
      @web_tester.select_lists.each { |select|
        next unless select.name == selectName
        assert_equal(select.value, optionValue, "Select #{selectName}'s value is not equal to expected: '#{optionValue}'")
      }
    end

    ##
    # radio

    # radioGroup is the name field, radio options 'value' field
    def assert_radio_option_not_present(radioGroup, radioOption)
      @web_tester.radios.each { |radio|
        if (radio.name == radioGroup) then
          assert(!(radioOption == radio.value), "unexpected radio option: " + radioOption  + " found")
        end
      }
    end

    def assert_radio_option_present(radioGroup, radioOption)
      @web_tester.radios.each { |radio|
        return if (radio.name == radioGroup) and (radioOption == radio.value)
      }
      fail("can't find the radio option : '#{radioOption}'")
    end

    def assert_radio_option_selected(radioGroup, radioOption)
      @web_tester.radios.each { |radio|
        if (radio.name == radioGroup and radioOption == radio.value) then
          assert(radio.isSet?, "Radio button #{radioGroup}-[#{radioOption}] not checked")
        end
      }
    end

    def assert_radio_option_not_selected(radioGroup, radioOption)
      @web_tester.radios.each { |radio|
        if (radio.name == radioGroup and radioOption == radio.value) then
          assert(!radio.isSet?, "Radio button #{radioGroup}-[#{radioOption}] checked unexpected")
        end
      }
    end

    ##
    # Button
    def assert_button_not_present(buttonId)
      @web_tester.buttons.each { |button|
        assert(button.id != buttonId, "unexpected button id: #{buttonId} found")
      }
    end

    def assert_button_not_present_with_text(text)
      @web_tester.buttons.each { |button|
        assert(button.value != text, "unexpected button id: #{text} found")
      }
    end

    def assert_button_present(buttonID)
      @web_tester.buttons.each { |button|
        return if buttonID == button.id
      }
      assert(false, "can't find the button with id: #{buttonID}")
    end

    def assert_button_present_with_text(buttonText)
      @web_tester.buttons.each { |button|
        return if buttonText == button.value
      }
      assert(false, "can't find the button with text: #{buttonText}")
    end

    ##
    # Link
    def assert_link_present_with_exact(linkText)
      @web_tester.links.each { |link|
        return if linkText == link.text
      }
      fail( "can't find the link with text: #{linkText}")
    end

    def assert_link_not_present_with_exact(linkText)
      @web_tester.links.each { |link|
        assert(linkText != link.text, "unexpected link (exact): #{linkText} found")
      }
    end

    def assert_link_present_with_text(linkText)
      @web_tester.links.each { |link|
        return if link.text.include?(linkText)
      }
      fail( "can't find the link containing text: #{linkText}")
    end

    def assert_link_not_present_with_text(linkText)
      @web_tester.links.each { |link|
        assert(!link.text.include?(linkText), "unexpected link containing: #{linkText} found")
      }
    end

    def assert_text_present_in_text_field(textfieldName, text, msg = nil)
      @web_tester.textfields.each { |textfield|
        if (textfield.name == textfieldName) then
          assert(text_field.value.include?(text), "text: #{text} not in text field: " + textfieldName)
        end
      }
    end

    # assertions
    def assert_title_equals(title)
      assert_equals(title, @web_tester.page_title)
    end

    def assert_equals(expected, actual, msg=nil)
      assert(expected == actual, (msg.nil?) ? "Expected: #{expected} diff from actual: #{actual}" : msg)
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

  end
end

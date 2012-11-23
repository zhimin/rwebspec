module RWebSpec
    module ElementLocator

      BUTTON_VALID_TYPES = %w[button reset submit image]
      def button_elements
        find_elements(:xpath, ".//button | .//input[#{attribute_expression :type => BUTTON_VALID_TYPES}]")
      end

      CHECK_BOX_TYPES = %w(checkbox)
      def check_box_elements(how, what, opts = [])
        find_elements(:xpath, ".//input[#{attribute_expression :type => CHECK_BOX_TYPES}]")
      end

      RADIO_TYPES = %w(radio)
      def radio_elements(how, what, opts = [])
        find_elements(:xpath, ".//input[#{attribute_expression :type => RADIO_TYPES}]")
      end

      def select_elements(how, what, opts = [])
        find_elements(:xpath, ".//input[#{attribute_expression :type => RADIO_TYPES}]")
      end

      # TextField, TextArea
      TEXT_FILED_TYPES = %w(text)
      def text_field_elements
        find_elements(:xpath, ".//input[#{attribute_expression :type => TEXT_FILED_TYPES}]")
      end

      def text_area_elements
        find_elements(:xpath, ".//textarea")
      end

      FILE_FIELD_TYPES = %w(file)
      def file_field_elements
        find_elements(:xpath, ".//input[#{attribute_expression :type => FILE_FIELD_TYPES}]")
      end

      HIDDEN_TYPES = %w(hidden)
      def hidden_elements
        find_elements(:xpath, ".//input[#{attribute_expression :type => HIDDEN_TYPES}]")
      end

      #---
      def find_by_tag(tag)
        find_elements(:tag_name, tag)
      end

      def should_use_label_element?
        @selector[:tag_name] != "option" rescue false
      end

      def equal_pair(key, value)
        # we assume :label means a corresponding label element, not the attribute
        if key == :label && should_use_label_element?
          "@id=//label[normalize-space()='#{value}']/@for"
        else
          "#{lhs_for(key)}='#{value}'"
        end
      end

      def lhs_for(key)
        case key
        when :text, 'text'
          'normalize-space()'
        when :href
          # TODO: change this behaviour?
          'normalize-space(@href)'
        else
          "@#{key.to_s.gsub("_", "-")}"
        end
      end


      def attribute_expression(selectors)
        selectors.map do |key, val|
          if val.kind_of?(Array)
            "(" + val.map { |v| equal_pair(key, v) }.join(" or ") + ")"
          else
            equal_pair(key, val)
          end
        end.join(" and ")
      end

    end

end

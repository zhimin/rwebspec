#***********************************************************
#* Copyright (c) 2006, Zhimin Zhan.
#* Distributed open-source, see full license in MIT-LICENSE
#***********************************************************

# useful hekoer methods for testing
#
module RWebUnit
  module Utils

    # default date format returned is 29/12/2007.
    # if supplied parameter is not '%m/%d/%Y' -> 12/29/2007
    # Otherwise, "2007-12-29", which is most approiate date format
    def today(format = '%d/%m/%y')
      if format.downcase == '%d/%m/%y'
        format_date(Time.now, "%02d/%02d/%04d")
      elsif format.downcase == '%m/%d/%y'
        sprintf("%02d/%02d/%04d", Time.now.month, Time.now.day, Time.now.year)
      else
        sprintf("%04d-%02d-%02d", Time.now.year, Time.now.month, Time.now.day)
      end
    end
    alias getToday_AU today
    alias getToday_US today
    alias getToday today


    def days_before(days)
      nil if !(days.instance_of?(Fixnum))
      format_date(Time.now - days * 24 * 3600)
    end

    def yesterday
      days_before(1)
    end

    def days_from_now(days)
      nil if !(days.instance_of?(Fixnum))
      format_date(Time.now + days * 24 * 3600)
    end
    alias days_after days_from_now

    def tomorrow
      days_from_now(1)
    end

    # return a random number >= min, but <= max
    def random_number(min, max)
      rand(max-min+1)+min
    end

    def random_boolean
      return random_number(0, 1) == 1
    end

    def random_char(lowercase = true)
      sprintf("%c", random_number(97, 122)) if lowercase
      sprintf("%c", random_number(65, 90)) unless lowercase
    end

    def random_digit()
      sprintf("%c", random_number(48, 57))
    end

    def random_str(length, lowercase = true)
      randomStr = ""
      length.times {
        randomStr += random_char(lowercase)
      }
      randomStr
    end

    # Return a random string in a rangeof pre-defined strings
    def random_string_in(arr)
      return nil if arr.empty?
      index = random_number(0, arr.length-1)
      arr[index]
    end
    alias random_string_in_collection random_string_in


    WORDS = %w(alias consequatur aut perferendis sit voluptatem accusantium doloremque aperiam eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo aspernatur aut odit aut fugit sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt neque dolorem ipsum quia dolor sit amet consectetur adipisci velit sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem ut enim ad minima veniam quis nostrum exercitationem ullam corporis nemo enim ipsam voluptatem quia voluptas sit suscipit laboriosam nisi ut aliquid ex ea commodi consequatur quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae et iusto odio dignissimos ducimus qui blanditiis praesentium laudantium totam rem voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident sed ut perspiciatis unde omnis iste natus error similique sunt in culpa qui officia deserunt mollitia animi id est laborum et dolorum fuga et harum quidem rerum facilis est et expedita distinctio nam libero tempore cum soluta nobis est eligendi optio cumque nihil impedit quo porro quisquam est qui minus id quod maxime placeat facere possimus omnis voluptas assumenda est omnis dolor repellendus temporibus autem quibusdam et aut consequatur vel illum qui dolorem eum fugiat quo voluptas nulla pariatur at vero eos et accusamus officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae itaque earum rerum hic tenetur a sapiente delectus ut aut reiciendis voluptatibus maiores doloribus asperiores repellat)

     # Pick a random value out of a given range.
     def value_in_range(range)
       case range.first
       when Integer then number_in_range(range)
       when Time then time_in_range(range)
       when Date then date_in_range(range)
       else range.to_a.rand
       end
     end

     # Generate a given number of words. If a range is passed, it will generate
     # a random number of words within that range.
     def words(total)
       (1..interpret_value(total)).map { WORDS.rand }.join(' ')
     end

     # Generate a given number of sentences. If a range is passed, it will generate
     # a random number of sentences within that range.
     def sentences(total)
       (1..interpret_value(total)).map do
         words(5..20).capitalize
       end.join('. ')
     end

     # Generate a given number of paragraphs. If a range is passed, it will generate
     # a random number of paragraphs within that range.
     def paragraphs(total)
       (1..interpret_value(total)).map do
         sentences(3..8).capitalize
       end.join("\n\n")
     end

     # If an array or range is passed, a random value will be selected to match.
     # All other values are simply returned.
     def interpret_value(value)
       case value
       when Array then value.rand
       when Range then value_in_range(value)
       else value
       end
     end

     private

     def time_in_range(range)
       Time.at number_in_range(Range.new(range.first.to_i, range.last.to_i, range.exclude_end?))
     end

     def date_in_range(range)
       Date.jd number_in_range(Range.new(range.first.jd, range.last.jd, range.exclude_end?))
     end

     def number_in_range(range)
       if range.exclude_end?
         rand(range.last - range.first) + range.first
       else
         rand((range.last+1) - range.first) + range.first
       end
     end

    def format_date(date, date_format = nil)
      date_format ||=  "%02d/%02d/%04d"
      sprintf(date_format, date.day, date.month, date.year)
    end

  end
end

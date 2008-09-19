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

    private
    def format_date(date, date_format = nil)
      date_format ||=  "%02d/%02d/%04d"
      sprintf(date_format, date.day, date.month, date.year)
    end

  end
end

$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebunit")
$:.unshift File.dirname(__FILE__)

require "test_utils.rb"
require 'test/unit'

class TestWebTestCase < Test::Unit::TestCase
   include RWebUnit::Utils

   def setup
   end

   def teardown
   end

   def test_getToday
      today_str = sprintf("%02d/%02d/%04d", Time.now.day, Time.now.month, Time.now.year)
      assert_equal(today_str, getToday)
      assert_equal(today_str, today)
      assert_equal(sprintf("%04d-%02d-%02d", Time.now.year, Time.now.month, Time.now.day), today("blah"))
      assert_equal(sprintf("%02d/%02d/%04d", Time.now.month, Time.now.day,  Time.now.year), today("%m/%d/%Y"))
   end

   def test_getDaysBefore
      yesterday_date = Time.now - 24 * 3600 * 1
      yesterday_str = sprintf("%02d/%02d/%04d", yesterday_date.day, yesterday_date.month, yesterday_date.year)
      assert_equal(yesterday_str, days_before(1))
      assert_equal(yesterday_str, yesterday)
   end

   def test_future_date
      tomorrow_date = Time.now + 24 * 3600 * 1
      tomorrow_str = sprintf("%02d/%02d/%04d", tomorrow_date.day, tomorrow_date.month, tomorrow_date.year)
      assert_equal(tomorrow_str, days_from_now(1))
      assert_equal(tomorrow_str, tomorrow)
   end

   def test_randomBoolean
      true_count = 0
      false_count = 0
      100.times {
         obj = random_boolean
         assert(obj.instance_of?(TrueClass) || obj.instance_of?(FalseClass), "can only be true or false")
         true_count += 1 if obj
         false_count += 1 if !obj
      }
      assert(true_count > 0, "it is not random")
      assert(false_count > 0, "it is not random")
   end

   def test_random_number
      tmp_array = []
      1000.times {
         num = random_number(1,10)
         assert(num.instance_of?(Fixnum), "can only be number")
         tmp_array << num
      }
      uniq_numbers = tmp_array.uniq.sort
      assert_equal(10, uniq_numbers.length)
      assert_equal(1, uniq_numbers[0])
      assert_equal(10, uniq_numbers[9])
   end

   def test_random_digit
      tmp_array = []
      1000.times {
         dc = random_digit
         tmp_array << dc
      }
      uniq_digits = tmp_array.uniq.sort
      assert_equal(10, uniq_digits.length)
      assert_equal('0', uniq_digits[0])
      assert_equal('9', uniq_digits[9])
   end

end

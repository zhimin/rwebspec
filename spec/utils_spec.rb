require File.dirname(__FILE__) + "/stack"
$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebspec")
gem "rspec"
require File.join(File.dirname(__FILE__), "..", "lib/rspec_extensions.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/test_utils.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/assert.rb")

test_suite "Utils" do
  include RWebUnit::Utils
  include RWebUnit::Assert

  story "today" do
    today_str = sprintf("%02d/%02d/%04d", Time.now.day, Time.now.month, Time.now.year)
    assert_equal(today_str, today)
    assert_equal(sprintf("%02d/%02d/%04d", Time.now.month, Time.now.day,  Time.now.year), today("%m/%d/%Y"))
  end

  story "yesterday and days_before"  do
    yesterday_date = Time.now - 24 * 3600 * 1
    yesterday_str = sprintf("%02d/%02d/%04d", yesterday_date.day, yesterday_date.month, yesterday_date.year)
    assert_equal(yesterday_str, days_before(1))
    assert_equal(yesterday_str, yesterday)
  end

  story "future date" do
    tomorrow_date = Time.now + 24 * 3600 * 1
    tomorrow_str = sprintf("%02d/%02d/%04d", tomorrow_date.day, tomorrow_date.month, tomorrow_date.year)
    assert_equal(tomorrow_str, days_from_now(1))
    assert_equal(tomorrow_str, tomorrow)
  end
end

#END

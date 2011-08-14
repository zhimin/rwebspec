require File.dirname(__FILE__) + "/stack"
$:.unshift File.join(File.dirname(__FILE__), "..", "lib/rwebspec")
gem "rspec"
require File.join(File.dirname(__FILE__), "..", "lib/rspec_extensions.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/test_utils.rb")
require File.join(File.dirname(__FILE__), "..", "lib/rwebspec/assert.rb")

describe "Utils" do
  include RWebSpec::Utils
  include RWebSpec::Assert

  story "today" do
    today_str = sprintf("%02d/%02d/%04d", Time.now.day, Time.now.month, Time.now.year)
    assert_equal(today_str, today)
    assert_equal(sprintf("%02d/%02d/%04d", Time.now.month, Time.now.day,  Time.now.year), today("%m/%d/%Y"))
    # puts "us: " + yesterday(:us)
    # puts "uk: " + tomorrow(:uk)
    # puts "cn: " + today(:cn)
    assert today(:us) =~ /^\d{2}\/\d{2}\/\d{4}$/
    assert today(:uk) =~ /^\d{2}\/\d{2}\/\d{4}$/
    assert today(:cn) =~ /^\d{4}-\d{2}-\d{2}/
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
  
  story "random string" do
    str = random_str(20)
    assert_equal(20, str.size)
  end
  
  story "random string in collection" do
    str = random_string_in(["abc", "def"])
    assert str.class == String
    assert str == "abc" || str == "def"
  end
  
  story "random word" do
    word = words(2) # => sit aliquam
    assert_equal 2, word.split(" ").size        
  end
  
  story "random number" do
    100.times do
      a_number =  random_number(10, 20)
      assert a_number <= 20 && a_number >= 10
    end      
  end
  
  story "sum" do
      assert_equal 10, [1, 2, 3, 4].sum      
      assert_equal 15.5, [1, 2, 3, 4, 5.5].sum      
  end
  
  story "average" do
      assert_equal 2.5, [1, 2, 3, 4].average
  end
  
  it "words" do
     words(2).split(" ").size.should ==  2
  end
  
  it "sentences" do
     sentences(3).size.should > 20
  end

  it "paragraphs" do
    sentences(3).size.should > 60
  end
  
end

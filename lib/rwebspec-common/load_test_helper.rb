
module RWebSpec
  module LoadTestHelper

    include RWebSpec::Core
    include RWebSpec::Assert

    MAX_VU = 1000
    
    # only support firefox or Celerity
    def open_browser(base_url, options = {})
      default_options = {:resynchronize => false, :firefox => false }      
      options = default_options.merge(options)
      options[:firefox] ||= (ENV['LOADWISE_PREVIEW'] || $LOADWISE_PREVIEW)
      RWebSpec::WebBrowser.new(base_url, nil, options)
    end

    # maybe attach_browser

    # Does not provide real function, other than make enhancing test syntax
    #
    # Example:
    #   allow { click_button('Register') }
    def allow(&block)
      yield
    end
    alias shall_allow  allow
    alias allowing  allow

    # try operation, ignore if errors occur
    #
    # Example:
    #   failsafe { click_link("Logout") }  # try logout, but it still OK if not being able to (already logout))
    def failsafe(&block)
      begin
        yield
      rescue =>e
      end
    end
    alias fail_safe failsafe

    # Try the operation up to specified timeout (in seconds), and sleep given interval (in seconds).
    # Error will be ignored until timeout
    # Example
    #    try { click_link('waiting')}
    #    try(10, 2) { click_button('Search' } # try to click the 'Search' button upto 10 seconds, try every 2 seconds
    #    try { click_button('Search' }
    def try(timeout = $testwise_polling_timeout, polling_interval = $testwise_polling_interval || 1, &block)
      start_time = Time.now

      last_error = nil
      until (duration = Time.now - start_time) > timeout
        begin
          return if yield
          last_error = nil
        rescue => e
          last_error = e
        end
        sleep polling_interval
      end

      raise "Timeout after #{duration.to_i} seconds with error: #{last_error}." if last_error
      raise "Timeout after #{duration.to_i} seconds."
    end
    alias try_upto try

    ##
    #  Convert :first to 1, :second to 2, and so on...
    def symbol_to_sequence(symb)
      value = { :zero => 0,
        :first => 1,
        :second => 2,
        :third => 3,
        :fourth => 4,
        :fifth => 5,
        :sixth => 6,
        :seventh => 7,
        :eighth => 8,
        :ninth => 9,
      :tenth => 10 }[symb]
      return value || symb.to_i
    end

    # monitor current execution using
    #
    # Usage
    #  log_time { browser.click_button('Confirm') }
    def log_time(msg, &block)
      start_time = Time.now
      yield
      end_time = Time.now
      
      Thread.current[:log] ||= []
      Thread.current[:log] << {:file => File.basename(__FILE__),
        :message => msg,
        :start_time => Time.now,
        :duration => Time.now - start_time}
        
      if $LOADWISE_MONITOR
      begin
         require 'java'
         puts "Calling Java 1"         
         java_import com.loadwise.db.MemoryDatabase
         #puts "Calling Java 2: #{MemoryDatabase.count}"         
         MemoryDatabase.addEntry(1, "zdfa01", "a_spec.rb", msg, start_time, end_time);           
         puts "Calling Java Ok: #{MemoryDatabase.count}"
      rescue NameError => ne
         puts "Name Error: #{ne}"
         # failed to load Java class
      rescue => e
         puts "Failed to calling Java: #{e.class.name}"
      end
      end
      # How to notify LoadWise at real time
      # LoadWise to collect CPU 
    end

    def run_with_virtual_users(virtual_user_count = 2, preview = false, &block)
      raise "too many virtual users" if virtual_user_count > MAX_VU
      
      begin
        if defined?(LOADWISE_PREVIEW)
          preview = LOADWISE_PREVIEW
        end
      rescue => e1
      end
      
      if preview
        virtual_user_count = 1 
        $LOADWISE_PREVIEW = true
      end
      
      if (virtual_user_count <= 1)
        yield
      else
        threads = []
        vu_reports = {}
        virtual_user_count.times do |idx|
          threads[idx] = Thread.new do
            start_time = Time.now
            vu_reports[idx] ||= []
            begin
              yield
              vu_reports[idx] =  Thread.current[:log]
            rescue => e
              vu_reports[idx] =  Thread.current[:log]
              vu_reports[idx] ||= []
              vu_reports[idx] << { :error => e }
            end
            vu_reports[idx] ||= []
            vu_reports[idx] << { :message => "Total Duration", :duration => Time.now - start_time }            
            puts "VU[#{idx+1}] #{Time.now - start_time}s"
          end
        end

        threads.each {|t| t.join; }
        vu_reports.each do |key, value|
          value.each do |entry|
            if entry[:error] then
              puts "Error: #{entry[:error]}"
            else
              puts "[#{key}] #{entry[:message]}, #{entry[:duration]}"
            end
          end
        end

        return vu_reports
      end
    end

  end
end

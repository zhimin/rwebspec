
module RWebSpec
  module LoadTestHelper

    include RWebSpec::Utils
    include RWebSpec::Assert

    # only support firefox or Celerity
    def open_browser(base_url, options)
      options[:firefox] ||= (ENV['ILOAD2_PREVIEW'] == true)
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
    def try(timeout = @@default_timeout, polling_interval = @@default_polling_interval || 1, &block)
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
      Thread.current[:log] ||= []
      Thread.current[:log] << [File.basename(__FILE__), msg, Time.now, Time.now - start_time]
    end

	def run_with_virtual_users(virtual_user_count = 2, &block)		
	  	raise "too many virtual users" if virtual_user_count > 100 #TODO
	  	if (virtual_user_count <= 1) 
	  		yield	  	
	  	else 
		threads = [] 
		virtual_user_count.times do |idx|
  			threads[idx] = Thread.new do
    			start_time = Time.now 
    			yield
    			puts "Thread[#{idx+1}] #{Time.now - start_time}s"
  			end
		end

		threads.each {|t| t.join }
		end
	end

  end
end

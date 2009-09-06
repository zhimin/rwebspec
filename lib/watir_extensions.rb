if RUBY_PLATFORM == "java" then
  # no need to load firefox extension
else
  module FireWatir
    class Firefox

      @@firefox_started = false

      def initialize(options = {})
        if(options.kind_of?(Integer))
          options = {:waitTime => options}
        end

        if(options[:profile])
          profile_opt = "-no-remote -P #{options[:profile]}"
        else
          profile_opt = ""
        end

        waitTime = options[:waitTime] || 2
        
        os = RUBY_PLATFORM
        if RUBY_PLATFORM =~ /java/ then
          require 'rbconfig'
          os = Config::CONFIG['host_os']
        end
        
        case os
        when /mswin/
          # Get the path to Firefox.exe using Registry.
          require 'win32/registry.rb'
          path_to_bin = ""
          Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Mozilla\Mozilla Firefox') do |reg|
            keys = reg.keys
            reg1 = Win32::Registry::HKEY_LOCAL_MACHINE.open("SOFTWARE\\Mozilla\\Mozilla Firefox\\#{keys[0]}\\Main")
            reg1.each do |subkey, type, data|
              if(subkey =~ /pathtoexe/i)
                path_to_bin = data
              end
            end
          end

        when /linux/i
          path_to_bin = `which firefox`.strip
        when /darwin/i
          path_to_bin = '/Applications/Firefox.app/Contents/MacOS/firefox'
        when /java/          
          raise "Error, should have set using rbconfig: #{os}"
        end

        @t = Thread.new { system("#{path_to_bin} -jssh #{profile_opt}")} unless @@firefox_started

        sleep waitTime
        begin
          set_defaults()
        rescue Watir::Exception::UnableToStartJSShException
          if !@t # no new thread starting browser, try again
            puts "Firefox with JSSH not detected after you indicated @@firefox_started"
            @t = Thread.new { system("#{path_to_bin} -jssh #{profile_opt}")}
            sleep waitTime
            set_defaults
          end
        end
        get_window_number()
        set_browser_document()
      end

      def self.firefox_started=(value)
        @@firefox_started = value
      end

    end
  end

end

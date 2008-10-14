require 'socket'

module RWebUnit
  module ITestPlugin

    def connect_to_itest(message_type, body)
      begin
        the_message = message_type + "|" + body
        if @last_message == the_message then
          return
        end
        itest_port = $ITEST2_TRACE_PORT || 7025
        itest_socket = Socket.new(Socket::AF_INET,Socket::SOCK_STREAM,0)
        itest_socket.connect(Socket.pack_sockaddr_in(itest_port, 'localhost'))
        itest_socket.puts(the_message)
        @last_message = the_message
        itest_socket.close
      rescue => e
      end
    end

    def debug(message)
      connect_to_itest(" DEBUG", message + "\r\n") if $RUN_IN_ITEST
    end

    # find out the line (and file) the execution is on, and notify iTest via Socket
    def dump_caller_stack
      return unless $ITEST2_TRACE_EXECUTION
      begin
        caller.each_with_index do |position, idx|
          next unless position =~ /\A(.*?):(\d+)/
          file = $1
          # TODO: send multiple trace to be parse with pages.rb
          # next if file =~ /example\/example_methods\.rb$/ or file =~ /example\/example_group_methods\.rb$/ or file =~ /driver\.rb$/ or file =~ /timeout\.rb$/ # don't include rspec or ruby trace

          if file.include?("_spec.rb")
            connect_to_itest(" TRACE", position)
          end

          break if idx > 4 or file =~ /"_spec\.rb$/
        end
      rescue => e
        puts "failed to capture log: #{e}"
      end
    end
  end
end

require 'socket'

module RWebSpec
  module ITestPlugin

    def connect_to_itest(message_type, body)
      begin
        the_message = message_type + "|" + body
        if @last_message == the_message then # ignore the message same as preivous one
          return
        end
        itest_port = $ITEST2_TRACE_PORT || 7025
        itest_socket = Socket.new(Socket::AF_INET,Socket::SOCK_STREAM,0)
        itest_socket.connect(Socket.pack_sockaddr_in(itest_port, '127.0.0.1'))
        itest_socket.puts(the_message)
        @last_message = the_message
        itest_socket.close
      rescue => e
      end
    end
    alias connect_to_itest2 connect_to_itest

    def debug(message)
      connect_to_itest(" DEBUG", message + "\r\n") if $RUN_IN_ITEST
    end


    # Support of iTest to ajust the intervals between keystroke/mouse operations
    def operation_delay
      begin
        if $ITEST2_OPERATION_DELAY && $ITEST2_OPERATION_DELAY > 0 &&
          $ITEST2_OPERATION_DELAY && $ITEST2_OPERATION_DELAY < 30000  then # max 30 seconds
            sleep($ITEST2_OPERATION_DELAY / 1000)
        end

        while $ITEST2_PAUSE
            debug("Paused, waiting ...")
            sleep 1
        end
      rescue => e
        puts "Error on delaying: #{e}"
        # ignore
      end
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

          if file.include?("_spec.rb") || file.include?("_test.rb") || file.include?("_cmd.rb")
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

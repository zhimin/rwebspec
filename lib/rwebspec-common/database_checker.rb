require 'active_record' # change rwebspec/database

module RWebSpec
  module DatabaseChecker

    # Example
    #   connect_to_database mysql_db(:host => "localhost", :database => "lavabuild_local", :user => "root", :password => ""), true
    def mysql_db(settings)
      options = {:adapter => "mysql"}
      options.merge!(settings)
    end

    # connect_to_database sqlite3_db(:database => File.join(File.dirname(__FILE__), "testdata", "sample.sqlite3")), true
    def sqlite3_db(settings)
      options = {:adapter => "sqlite3"}
      options.merge!(settings)
    end

    def sqlserver_db(settings)
      options = {:adapter => "sqlserver"}
      options[:username] ||= settings[:user]
      options.merge!(settings)
    end

    def sqlserver_db_dbi(options)
      options[:user] ||= options[:username]
      options[:username] ||= options[:user]
      conn_str = "DBI:ADO:Provider=SQLOLEDB;Data Source=#{options[:host]};Initial Catalog=#{options[:database]};User ID=\"#{options[:user]}\";password=\"#{options[:password]}\" "
      dbh = DBI.connect(conn_str)
    end

    def clear_database_connection
      begin
        ActiveRecord::Base.remove_connection
      rescue => e
        puts "failed o clear database connection: #{e}"
      end
    end

    # Connect to databse, example
    #   mysql_db(:host => "localhost", :database => "lavabuild_local", :user => "root", :password => "")
    def connect_to_database(db_settings, force = false)
      # only setup database connection once
      if force
        ActiveRecord::Base.establish_connection(db_settings)
      else
        begin
          ActiveRecord::Base.connection
        rescue => e
          require 'pp'
          pp db_settings
          puts "failed to connect: #{e}"
          ActiveRecord::Base.establish_connection(db_settings)
        end
      end
    end

    def load_table(table_name)
      begin
        ActiveRecord::Base.connection
      rescue =>e
        raise "No database connection setup yet, use connect_to_database() method"
      end
      class_name = table_name.classify
      # define the class, so can use ActiveRecord in
      # such as
      #   Perosn.count.should == 2
      def_class = "class ::#{class_name} < ActiveRecord::Base; end"
      eval def_class
      return def_class
    end

  end
end

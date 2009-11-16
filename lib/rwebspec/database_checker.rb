require 'active_record' # change rwebspec/database

module RWebSpec
  module DatabaseChecker

    def mysql_db(settings)
      options = {:adapter => "mysql"}
      options.merge!(settings)
    end

    def sqlite3_db(settings)
      options = {:adapter => "sqlite3"}
      options.merge!(settings)
    end

    # Connect to databse, example
    #   mysql_db(:host => "localhost", :database => "lavabuild_local", :user => "root", :password => "")
    def connect_to_database(db_settings, force => false) 
        # only setup database connection once
        if force || ActiveRecord::Base.connection.nil?
          ActiveRecord::Base.establish_connection(db_settings)
        end        
    end
    
    def load_table(table_name)
      raise "No database connection setup yet, use connect_to_database() method" unless ActiveRecord::Base.connection
      class_name = table_name.classify
      # define the class, so can use ActiveRecord in 
      # such as 
      #   Perosn.count.should == 2
      def_class = "class #{class_name} < ActiveRecord::Base; end"
      eval(def_class);
      return class_name
    end

  end
end

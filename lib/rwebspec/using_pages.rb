module RWebUnit
  module UsingPages

    # support Ruby 1.9
    def self.extended(kclass)
      caller_file = caller[1]
      if caller_file && caller_file =~ /^(.*):\d+.*$/ 
        file = $1
        dir = File.expand_path(File.dirname(file))
        kclass.const_set "TestFileDir", dir
      end
    end

    # Example
    #  pages :all
    #  pages :login_page, :payment_page
    #  pages :login_page, :payment_page, :page_dir => "c:/tmp"
    def pages(*args)
      return if args.nil? or args.empty?

      test_file_dir = class_eval{  self::TestFileDir }
      default_page_dir = File.join(test_file_dir, "pages")
      #puts "debug: default_page_dir :#{default_page_dir}}"
      page_dir = default_page_dir

      page_files = []
      args.each do |x|
        if x.class == Hash && x[:page_dir]
          page_dir = x[:page_dir]
        else
          page_files << x
        end
      end

      if page_files.size == 1 && page_files[0] == :all
        Dir[File.expand_path(page_dir)+ "/*_page.rb"].each { |page_file|
          load page_file
        }
        return
      end

      page_files.each do |page|
        page_file = File.join(page_dir, page.to_s)
        load page_file
      end
    end

  end
end

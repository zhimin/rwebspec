require 'rubygems'
require 'rspec/core/rake_task'
require 'rdoc/task'
require 'rubygems/package_task'

require 'rdoc' # require rdoc 2
# gem 'darkfish-rdoc'
# require 'darkfish-rdoc'

$:.unshift(File.dirname(__FILE__) + "/lib")
#require 'rwebspec'

desc "Default task"
task :default => [ :clean, :spec, :rdoc, :chm, :gem]

desc "Continous build"
task :build => [:clean, :spec]

desc "Clean generated files"
task :clean do
  rm_rf 'pkg'
  rm_rf 'doc'
  rm_rf 'chm'
end

desc 'Run all specs'
RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = ['']
  # t.libs = ["lib", "server/lib" ]
  t.pattern = Dir['spec/**/*_spec.rb'].sort
end

# Generate the RDoc documentation
# Rake::RDocTask.new { |rdoc|
#   rdoc.rdoc_dir = 'doc'
#   rdoc.title = 'rWebUnit'
#   rdoc.template = "#{ENV['template']}.rb" if ENV['template']
#   rdoc.rdoc_files.include('README')
#   rdoc.rdoc_files.include('lib/rwebspec.rb')
#   rdoc.rdoc_files.include('lib/rwebspec/*.rb')
# }


# using DarkFish - http://deveiate.org/projects/Darkfish-Rdoc/
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'RWebSpec'
  rdoc.rdoc_files.include('lib/rwebspec.rb')
  rdoc.rdoc_files.include('lib/rwebspec-common/*.rb')  
  rdoc.rdoc_files.include('lib/rwebspec-common/matchers/*.rb')  
  rdoc.rdoc_files.include('lib/rwebspec-watir/*.rb')  
  rdoc.rdoc_files.include('lib/rwebspec-webdriver/*.rb')  
  rdoc.rdoc_files.include('lib/extensions/*.rb')  
  rdoc.rdoc_files.delete("lib/rwebspec/web_testcase.rb")
  rdoc.rdoc_files.delete("lib/rwebspec/checkJSDialog.rb")
  rdoc.options += [
        '-SHN',
        '-f', 'darkfish',  # This is the important bit
  ]
end

Rake::RDocTask.new("chm") do |rdoc|
  rdoc.rdoc_dir = 'chm'
  rdoc.title = 'RWebSpec'
  rdoc.rdoc_files.include('lib/rwebspec.rb')
  rdoc.rdoc_files.include('lib/rwebspec-common/*.rb')
  rdoc.rdoc_files.include('lib/rwebspec-watir/*.rb')
  rdoc.rdoc_files.include('lib/rwebspec-selenium/*.rb')
  rdoc.rdoc_files.delete("lib/rwebspec/web_testcase.rb")
  rdoc.rdoc_files.delete("lib/rwebspec/checkJSDialog.rb")
    rdoc.options += [
        '-SHN',
        '-f', 'chm',  # This is the important bit
      ]
end

spec = Gem::Specification.new do |s|
  s.platform= Gem::Platform::RUBY
  s.name = "rwebspec"
  s.version = "6.0.2"
  s.summary = "Web application functional specification in Ruby"
  s.description = "Executable functional specification for web applications in RSpec syntax with Watir or Selenium WebDriver"

  s.author  = "Zhimin Zhan"
  s.email   = "zhimin@agileway.com.au"
  s.homepage= "http://github.com/zhimin/rwebspec/tree/master"
  s.rubyforge_project = "rwebspec"
  s.licenses = ["MIT"]
  
  s.has_rdoc    = true
  s.requirements << 'none'
  s.require_path    = "lib"
  s.autorequire     = "rwebspec"

  s.files = [ "Rakefile", "README", "CHANGELOG", "MIT-LICENSE" ]
  s.files = s.files + Dir.glob( "lib/**/*" )
  s.files = s.files + Dir.glob( "test/**/*" )
  s.files = s.files + Dir.glob( "sample/**/*")
  s.files = s.files + Dir.glob( "docs/**/*" )

  s.add_dependency(%q<rspec>, ["~> 3.0"])
  s.add_dependency(%q<rspec-core>, ["~> 3.0"])
  s.add_dependency(%q<rspec-mocks>, ["~> 3.0"])
  s.add_dependency(%q<rspec-expectations>, ["~> 3.0"])
  s.add_dependency("commonwatir", "~> 4.0.0")

  s.add_dependency("activesupport", ">= 3.2.17")
  # s.add_dependency("ci_reporter", "~> 1.9.2")
    
  unless RUBY_PLATFORM =~ /mingw/
    s.add_dependency("selenium-webdriver", "~> 2.42")
  else
    s.add_dependency("watir-classic", "~> 4.0.1")
  end
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
end

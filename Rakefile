require 'rubygems'
require 'rake/testtask'
require 'rake/rdoctask'

Gem::manage_gems
require 'rake/gempackagetask'

$:.unshift(File.dirname(__FILE__) + "/lib")
#require 'rwebunit'

desc "Default task"
task :default => [ :clean, :test, :doc, :gem]

desc "Clean generated files"
task :clean do
  rm_rf 'pkg'
  rm_rf 'doc'
end

# run the unit tests
Rake::TestTask.new("test") { |t|
  t.test_files = FileList['test/test*.rb']
  t.verbose= true
}

# Generate the RDoc documentation
Rake::RDocTask.new { |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'rWebUnit'
  rdoc.template = "#{ENV['template']}.rb" if ENV['template']
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/rwebunit.rb')
  rdoc.rdoc_files.include('lib/rwebunit/*.rb')
}

spec = Gem::Specification.new do |s|
  s.platform= Gem::Platform::RUBY
  s.name = "rwebunit"
  s.version = "0.9.10"
  s.summary = "An wrap of WATIR/FireWatir for functional testing of web applications"
# s.description = ""

  s.author  = "Zhimin Zhan"
  s.email   = "zhimin@agileway.net"
  s.homepage= "http://code.google.com/p/rwebunit/"
  s.rubyforge_project = "rwebunit"

  s.has_rdoc    = true
  s.requirements << 'none'
  s.require_path    = "lib"
  s.autorequire     = "rwebunit"

  s.files = [ "Rakefile", "README", "CHANGELOG", "MIT-LICENSE" ]
#  s.files = s.files + Dir.glob( "bin/**/*" ).delete_if { |item| item.include?( "\.svn" ) }
  s.files = s.files + Dir.glob( "lib/**/*" ).delete_if { |item| item.include?( "\.svn" ) }
  s.files = s.files + Dir.glob( "test/**/*" ).delete_if { |item| item.include?( "\.svn" ) }
  s.files = s.files + Dir.glob( "sample/**/*" ).delete_if { |item| item.include?( "\.svn" ) }
  s.files = s.files + Dir.glob( "docs/**/*" ).delete_if { |item| item.include?( "\.svn" ) }
  s.add_dependency(%q<rspec>, [">= 1.1.4"])
#  s.add_dependency("watir", ">= 1.5.4")
#  s.add_dependency("firewatir", ">= 1.1")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
end



require 'rubygems'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rdoc' # require rdoc 2
gem 'darkfish-rdoc'
# require 'darkfish-rdoc'

$:.unshift(File.dirname(__FILE__) + "/lib")
#require 'rwebspec'

desc "Default task"
task :default => [ :clean, :spec, :gem]
# task :default => [ :clean, :spec, :rdoc, :gem]

desc "Clean generated files"
task :clean do
  rm_rf 'pkg'
  rm_rf 'doc'
end

desc 'Run all specs'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = ['--format', 'specdoc', '--colour']
  # t.libs = ["lib", "server/lib" ]
  t.spec_files = Dir['spec/**/*_spec.rb'].sort
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
  rdoc.title = 'rWebUnit'
  rdoc.rdoc_files.include('lib/rwebspec.rb')
  rdoc.rdoc_files.include('lib/rwebspec/*.rb')
    rdoc.options += [
        '-SHN',
        '-f', 'darkfish',  # This is the important bit
      ]
end

spec = Gem::Specification.new do |s|
  s.platform= Gem::Platform::RUBY
  s.name = "rwebspec"
  s.version = "1.4.0"
  s.summary = "Executable functional specification for web applications in RSpec syntax and Watir"
  # s.description = ""

  s.author  = "Zhimin Zhan"
  s.email   = "zhimin@agileway.net"
  s.homepage= "http://github.com/zhimin/rwebspec/tree/master"
  s.rubyforge_project = "rwebspec"

  s.has_rdoc    = true
  s.requirements << 'none'
  s.require_path    = "lib"
  s.autorequire     = "rwebspec"

  s.files = [ "Rakefile", "README", "CHANGELOG", "MIT-LICENSE" ]
  s.files = s.files + Dir.glob( "lib/**/*" )
  s.files = s.files + Dir.glob( "test/**/*" )
  s.files = s.files + Dir.glob( "sample/**/*")
  s.files = s.files + Dir.glob( "docs/**/*" )
  s.add_dependency(%q<rspec>, ["= 1.1.12"])
  s.add_dependency("commonwatir", ">= 1.6.2")
  s.add_dependency("test-unit", ">= 2.0.2")
  #  s.add_dependency("watir", ">= 1.6.2")
  #  s.add_dependency("firewatir", ">= 1.6.2")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
end

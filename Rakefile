require 'rubygems'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

$:.unshift(File.dirname(__FILE__) + "/lib")
#require 'rwebunit'

desc "Default task"
task :default => [ :clean, :spec, :rdoc, :gem]

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
  s.version = "1.2.2"
  s.summary = "An wrap of WATIR/FireWatir for functional testing of web applications"
  # s.description = ""

  s.author  = "Zhimin Zhan"
  s.email   = "zhimin@agileway.net"
  s.homepage= "http://github.com/zhimin/rwebunit/tree/master"
  s.rubyforge_project = "rwebunit"

  s.has_rdoc    = true
  s.requirements << 'none'
  s.require_path    = "lib"
  s.autorequire     = "rwebunit"

  s.files = [ "Rakefile", "README", "CHANGELOG", "MIT-LICENSE" ]
  s.files = s.files + Dir.glob( "lib/**/*" )
  s.files = s.files + Dir.glob( "test/**/*" )
  s.files = s.files + Dir.glob( "sample/**/*")
  s.files = s.files + Dir.glob( "docs/**/*" )
  s.add_dependency(%q<rspec>, [">= 1.1.12"])
  s.add_dependency("commonwatir", ">= 1.6.2")
  s.add_dependency("test-unit", ">= 2.0.2")
  #  s.add_dependency("watir", ">= 1.6.2")
  #  s.add_dependency("firewatir", ">= 1.6.2")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
end

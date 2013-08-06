# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rwebspec}
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Zhimin Zhan"]
  s.date = %q{2011-10-14}
  s.email = %q{zhimin@agileway.net}
  s.licenses = ["MIT"]
  s.files = ["Rakefile", "README", "CHANGELOG", "MIT-LICENSE", "lib/extensions/rspec_extensions.rb", "lib/rwebspec", "lib/rwebspec/assert.rb", "lib/rwebspec/clickJSDialog.rb", "lib/rwebspec/context.rb", "lib/rwebspec/driver.rb", "lib/plugins/testwise_plugin.rb", "lib/rwebspec/matchers", "lib/rwebspec/matchers/contains_text.rb", "lib/rwebspec/popup.rb", "lib/rwebspec/rspec_helper.rb", "lib/rwebspec/test_script.rb", "lib/rwebspec/core.rb", "lib/rwebspec/using_pages.rb", "lib/rwebspec/web_browser.rb", "lib/rwebspec/web_page.rb", "lib/rwebspec/web_testcase.rb", "lib/rwebspec.rb", "lib/extensions/watir_extensions.rb", "lib/rwebspec/load_test_helper.rb", "lib/rwebspec/database_checker.rb", "lib/extensions/window_script_extensions.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/zhimin/rwebspec/tree/master}
  s.require_paths = ["lib"]
  s.requirements = ["none"]
  s.rubyforge_project = %q{rwebspec}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Executable functional specification for web applications in RSpec syntax and Watir}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>, [">= 2.10"])
      s.add_runtime_dependency(%q<commonwatir>, [">= 3.0"])
    else
      s.add_dependency(%q<rspec>, [">= 2.10"])
      s.add_dependency(%q<commonwatir>, [">= 3.0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 2.10"])
    s.add_dependency(%q<commonwatir>, [">= 3.0"])
  end
end

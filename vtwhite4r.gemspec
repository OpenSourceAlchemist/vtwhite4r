# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{vtwhite4r}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["The Rubyists"]
  s.date = %q{2009-06-02}
  s.description = %q{A Ruby interface to the VTWhite Provisioning Web API}
  s.email = %q{rubyists@rubyists.com}
  s.files = ["README", "Rakefile", "lib/vtwhite4r.rb", "lib/vtwhite4r/error.rb", "lib/vtwhite4r/version.rb", "spec/helper.rb", "spec/invalid_test_submission.xml", "spec/not_authorized.xml", "tasks/authors.rake", "tasks/bacon.rake", "tasks/changelog.rake", "tasks/copyright.rake", "tasks/gem.rake", "tasks/gem_installer.rake", "tasks/install_dependencies.rake", "tasks/manifest.rake", "tasks/rcov.rake", "tasks/release.rake", "tasks/reversion.rake", "tasks/setup.rake", "tasks/yard.rake"]
  s.has_rdoc = true
  s.homepage = %q{}
  s.post_install_message = %q{============================================================

Thank you for installing Vtwhite4r!

============================================================}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A Ruby interface to the VTWhite Provisioning Web API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

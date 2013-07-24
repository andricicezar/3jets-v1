# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "angularjs-rails"
  s.version = "1.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hirav Gandhi"]
  s.date = "2013-05-28"
  s.description = "Injects Angular.js into your asset pipeline as well as other Angular modules."
  s.email = "hgandhi@alumni.stanford.edu"
  s.homepage = "https://github.com/hiravgandhi/angularjs-rails/"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Angular.js on Rails"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

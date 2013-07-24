# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "websocket-driver"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Coglan"]
  s.date = "2013-05-12"
  s.email = "jcoglan@gmail.com"
  s.extensions = ["ext/websocket_mask/extconf.rb"]
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md", "ext/websocket_mask/extconf.rb"]
  s.homepage = "http://github.com/faye/websocket-driver-ruby"
  s.rdoc_options = ["--main", "README.md", "--markup", "markdown"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "WebSocket protocol handler with pluggable I/O"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<eventmachine>, [">= 0"])
      s.add_development_dependency(%q<rake-compiler>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<rake-compiler>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<rake-compiler>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

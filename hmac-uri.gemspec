# -*- encoding: utf-8 -*-
# stub: hmac-uri 2.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "hmac-uri"
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Bharanee Rathna"]
  s.date = "2016-11-03"
  s.description = "OpenSSL based HMAC signing for request urls with shared secret"
  s.email = ["deepfryed@gmail.com"]
  s.files = ["CHANGELOG", "README.md", "lib/hmac-uri.rb", "lib/hmac/uri.rb", "test/helper.rb", "test/test_hmac_uri.rb"]
  s.homepage = "http://github.com/deepfryed/hmac-uri"
  s.required_ruby_version = Gem::Requirement.new(">= 2.1")
  s.rubygems_version = "2.2.2"
  s.summary = "HMAC signing for urls"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<addressable>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<addressable>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<addressable>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end

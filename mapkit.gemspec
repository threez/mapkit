# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mapkit}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.authors = ["Vincent Landgraf"]
  s.date = %q{2010-02-10}
  s.description = %q{MapKit is an set of helpers to assist building tiles for
  the google maps web client}
  s.email = ["vincent.landgraf@inovex.de"]
  s.files = ["lib/google_local.rb", "lib/mapkit.rb", "lib/tilekit.rb", "LICENSE", "README.markdown"]
  s.homepage = %q{http://github.com/threez/mapkit}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{MapKit helps rendering tiles for google maps}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0.5.2"])
      s.add_runtime_dependency(%q<gd2>, [">= 1.1.1"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0.5.2"])
      s.add_dependency(%q<gd2>, [">= 1.1.1"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0.5.2"])
    s.add_dependency(%q<gd2>, [">= 1.1.1"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mapkit'

Gem::Specification.new do |s|
  s.name 					= %q{mapkit}
  s.version 			= MapKit::VERSION
  s.authors 			= ["Vincent Landgraf", "Paul Trippett"]
  s.email 				= ["vilandgr@googlemail.com"]
  s.description 	= %q{
		MapKit is an set of helpers to assist building tiles for
		the google maps web client using rmagick
	}
  s.summary 			= 'MapKit helps rendering tiles for google maps'
  s.homepage 		  = 'http://github.com/threez/mapkit'
  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_dependency('httparty', ">= 0.5.2")
  s.add_dependency('rmagick', ">= 2.13.3")
end

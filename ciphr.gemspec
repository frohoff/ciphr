# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ciphr/version'

Gem::Specification.new do |spec|
  spec.name          = "ciphr"
  spec.version       = Ciphr::VERSION
  spec.authors       = ["Chris Frohoff"]
  spec.email         = ["chris@frohoff.org"]
  spec.description   = "" 
  spec.summary       = "gem for composing (en|de)coding, digest, cipher operations" 
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency 'coveralls'

  spec.add_dependency "parslet"
  spec.add_dependency "base32"
  #spec.add_dependency "base32-crockford"
  #spec.add_dependency "zbase32"
end

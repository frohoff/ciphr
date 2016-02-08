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

  spec.files         = Dir['**/*'] 
  spec.executables   = Dir['bin/**/*'] 
  spec.test_files    =  Dir['test/**/*', 'spec/**/*'] 
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.5.0"
  spec.add_development_dependency "rspec", "~> 3.4.0"
  #spec.add_development_dependency 'coveralls'
  #spec.add_development_dependency 'codeclimate-test-reporter'

  spec.add_dependency "parslet", "~> 1.5.0"
  spec.add_dependency "slop", "~> 3.6.0"
  spec.add_dependency "base32", "~> 0.3.2"
  #spec.add_dependency "base32-crockford"
  #spec.add_dependency "zbase32"
end

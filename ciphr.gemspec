# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ciphr/version'

Gem::Specification.new do |spec|
  spec.name          = "ciphr"
  spec.version       = Ciphr::VERSION
  spec.authors       = ["Chris Frohoff"]
  spec.email         = ["chris@frohoff.org"]
  spec.summary       = "a CLI tool for performing and composing encoding, decoding, encryption, decryption, hashing, and other various operations on streams of data from the command line; mostly intended for infosec uses." 
  spec.description   = "Ciphr is a CLI tool for performing and composing encoding, decoding, encryption, decryption, hashing, and other various operations on streams of data. It takes provided data, file data, or data from stdin, and executes a pipeline of functions on the data stream, writing the resulting data to stdout. It was designed primarily for use in the information security domain, mostly for quick or casual data manipulation for forensics, penetration testing, or capture-the-flag events; it likely could have other unforseen uses, but should be presumed to be an experimental toy as no effort was made to make included cryptographic functions robust against attacks (timing attacks, etc), and it is recommended not to use any included functions in any on-line security mechanisms." 
  spec.homepage      = "https://github.com/frohoff/ciphr"
  spec.license       = "MIT"
  
  spec.files         = Dir['**/*'] 
  spec.executables   << 'ciphr' 
  spec.test_files    =  Dir['test/**/*', 'spec/**/*'] 
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9.3"

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

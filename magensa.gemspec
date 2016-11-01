# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'magensa/version'

Gem::Specification.new do |spec|
  spec.name          = "magensa"
  spec.version       = Magensa::VERSION
  spec.authors       = ["Jonathan Spies"]
  spec.email         = ["jonathan.spies@gmail.com"]
  spec.description   = %q{Provides a simple interface to the Magensa Decryption Service}
  spec.summary       = %q{Provides a simple interface to the Magensa Decryption Service}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.add_dependency "savon", "2.11.1"
  
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov", "~> 0.11"
  spec.add_development_dependency "webmock", "~> 2.1"
  spec.add_development_dependency "codeclimate-test-reporter"
end

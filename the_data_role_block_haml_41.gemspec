# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'the_data_role_block_haml_41/version'

Gem::Specification.new do |spec|
  spec.name          = "the_data_role_block_haml_41"
  spec.version       = TheDataRoleBlockHaml41::VERSION
  spec.authors       = ["Ilya N. Zykin"]
  spec.email         = ["zykin-ilya@ya.ru"]
  spec.summary       = %q{data-role(@), data-block(@@) markers for HAML}
  spec.description   = %q{add data-role(@), data-block(@@) markers into your HAML templates}
  spec.homepage      = "https://github.com/data-role-block/the_data_role_block_haml_41"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'super_stack/version'

Gem::Specification.new do |spec|
  spec.name          = 'super_stack'
  spec.version       = SuperStack::VERSION
  spec.authors       = ['Laurent B.']
  spec.email         = ['lbnetid+gh@gmail.com']
  spec.summary       = %q{Provides a way to manage the merge of different hashes according to priority and several merge policies.}
  spec.description   = %q{The purpose of this gem is to provide a simple way to manage the merge of different hashes (layers) according to priority and several merge policies.}
  spec.homepage      = 'https://github.com/lbriais/super_stack'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'deep_merge', '~> 1.0'


end

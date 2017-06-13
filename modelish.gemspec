# -*- encoding: utf-8 -*-
# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'modelish/version'

Gem::Specification.new do |s|
  s.name        = 'modelish'
  s.version     = Modelish::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Maeve Revels']
  s.email       = ['maeve.revels@g5platform.com']
  s.homepage    = 'http://github.com/G5/modelish'
  s.summary     = 'A lightweight pseudo-modeling not-quite-framework'
  s.description = 'Sometimes you need something just a little modelish.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n")
                                           .map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency('hashie', '>= 1.0.0')

  s.add_development_dependency('appraisal')
  s.add_development_dependency('codeclimate-test-reporter')
  s.add_development_dependency('fuubar')
  s.add_development_dependency('rspec', '~> 3.6')
  s.add_development_dependency('rspec-its')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('yard', '~> 0.6')
  s.add_development_dependency('bluecloth', '~> 2.0')

  s.has_rdoc = true
end

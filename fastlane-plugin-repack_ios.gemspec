# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/repack_ios/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-repack_ios'
  spec.version       = Fastlane::RepackIos::VERSION
  spec.author        = 'Omer Duzyol'
  spec.email         = 'omer@duzyol.net'

  spec.summary       = 'Enables your build pipeline to repack your pre-built ipa with new assets without rebuilding the native code.'
  spec.homepage      = "https://github.com/creaworks-labs/fastlane-plugin-repack-ios"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_dependency('zip')

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.120.0')
end

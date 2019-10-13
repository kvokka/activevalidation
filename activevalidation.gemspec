# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "active_validation/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "activevalidation"
  spec.version     = ActiveValidation::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ["kvokka"]
  spec.email       = ["kvokka@yahoo.com"]
  spec.homepage    = "https://github.com/kvokka/activevalidation"
  spec.summary     = "Allow to store ActiveModel validations in ORM."
  spec.description = "Allow to store ActiveModel validations in ORM."
  spec.licenses    = ["MIT"]

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- test/*`.split("\n")
  spec.require_paths = ["lib"]

  # Minor version requirement adopted from zeitwerk gem
  spec.required_ruby_version = ">= 2.4.4"

  spec.add_dependency("activemodel",   ">= 5.0.0", "< 6.1")
  spec.add_dependency("activesupport", ">= 5.0.0", "< 6.1")
  spec.add_dependency("concurrent-ruby", ">= 1.0.0", "< 2.0")
  spec.add_dependency("zeitwerk", "~> 2.1.9")

  spec.add_development_dependency "activerecord", ">= 4.2.0", "< 6.1"
  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "database_cleaner", "~> 1.7.0"
  spec.add_development_dependency "factory_bot", "~> 5.0.0"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "simplecov", "~> 0.16"
  spec.add_development_dependency "turnip", "~> 4.0.0"
end

# frozen_string_literal: true

source "https://rubygems.org"
# git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in active_validation.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

group :local_development do
  gem "appraisal",  "~> 2.2.0"
  gem "overcommit", "~> 0.48.0"
  gem "pry",        "~> 0.12.0"
  gem "pry-byebug", "~> 3.7.0"
  gem "reek",       "~> 5.4.0"
  gem "rubocop",       "~> 0.72.0"
  gem "rubocop-rspec", "~> 1.32"
end

gem "mysql2",     "~> 0.5.2"     if ENV["DB"] == "mysql"
gem "pg",         "~> 1.0.0"     if ENV["DB"] == "postgres"
gem "sqlite3",    ">= 1.3.13"    if ENV["DB"] == "" || ENV["DB"] == "sqlite"

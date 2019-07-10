# frozen_string_literal: true

require "bundler/gem_tasks"

task gem: :build
task :build do
  system "gem build active_validation.gemspec"
end

task release: :build do
  system "git tag -a v#{ActiveValidation::VERSION} -m 'Tagging #{ActiveValidation::VERSION}'"
  system "git push --tags"
  system "gem push active_validation-#{ActiveValidation::VERSION}.gem"
  system "rm active_validation-#{ActiveValidation::VERSION}.gem"
end

require "rspec/core/rake_task"
desc "Run tests on ActiveValidation with RSpec"
task(:spec).clear
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false # hide list of specs bit.ly/1nVq3Jn
end

task default: %i[spec]

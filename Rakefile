# frozen_string_literal: true

require "bundler/gem_tasks"

desc "Run active validation tests for all ORMs."
task :pre_commit do
  Dir[File.join(File.dirname(__FILE__), "test", "orm", "*.rb")].each do |file|
    orm = File.basename(file).split(".").first
    # "Some day, my son, rake's inner wisdom will reveal itself.  Until then,
    # take this `system` -- may its brute force protect you well."
    exit 1 unless system "rake test DEVISE_ORM=#{orm}"
  end
end

desc "Delete generated files and databases"
task :clean do
  ::FileUtils.rm("spec/rails_app/db/database.yml", force: true)
  case ENV["DB"]
  when "mysql"
    %w[test].each do |db|
      system("mysqladmin drop -f active_validation_#{db} > /dev/null 2>&1")
    end
  when "postgres"
    %w[test].each do |db|
      system("dropdb --if-exists active_validation_#{db} > /dev/null 2>&1")
    end
  when nil, "", "sqlite"
    ::FileUtils.rm(::Dir.glob("spec/rails_app/db/*.sqlite3"))
  else
    raise "Don't know how to clean specified RDBMS: #{ENV['DB']}"
  end
end

desc "Write a database.yml for the specified RDBMS"
task prepare: [:clean] do
  ENV["DB"] ||= "sqlite"
  FileUtils.cp "spec/rails_app/config/database.#{ENV['DB']}.yml",
               "spec/rails_app/config/database.yml"
  case ENV["DB"]
  when "mysql"
    %w[test].each do |db|
      system("mysqladmin create active_validation_#{db}")
      # Migration happens later in spec_helper.
    end
  when "postgres"
    %w[test].each do |db|
      system("createdb active_validation_#{db}")
      # Migration happens later in spec_helper.
    end
  when "", "sqlite"
    nil
  else
    raise "Don't know how to create specified DB: #{ENV['DB']}"
  end
end

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

desc "Default: run tests for all ORMs."
task default: %i[prepare spec]

# frozen_string_literal: true

# Specify here only version constraints that differ from
# `active_validation.gemspec`.
#
# > The dependencies in your Appraisals file are combined with dependencies in
# > your Gemfile, so you don't need to repeat anything that's the same for each
# > appraisal. If something is specified in both the Gemfile and an appraisal,
# > the version from the appraisal takes precedence.
# > https://github.com/thoughtbot/appraisal

appraise "am-5.0" do
  gem "activerecord", "~> 5.0.0"
  gem "sqlite3",    "~> 1.3.13"    if ENV["DB"] == "" || ENV["DB"] == "sqlite"
	gem "mysql2",     "~> 0.5.2"     if ENV["DB"] == "mysql"
	gem "pg",         "~> 1.0.0"     if ENV["DB"] == "postgres"
end

appraise "am-5.1" do
  gem "activerecord", "~> 5.1.0"
  gem "sqlite3",    "~> 1.3.13"    if ENV["DB"] == "" || ENV["DB"] == "sqlite"
  gem "mysql2",     "~> 0.5.2"     if ENV["DB"] == "mysql"
  gem "pg",         "~> 1.0.0"     if ENV["DB"] == "postgres"
end

appraise "am-5.2" do
  gem "activerecord", "~> 5.2.0"
  gem "sqlite3",    "~> 1.3.13"    if ENV["DB"] == "" || ENV["DB"] == "sqlite"
  gem "mysql2",     "~> 0.5.2"     if ENV["DB"] == "mysql"
  gem "pg",         "~> 1.0.0"     if ENV["DB"] == "postgres"
end

appraise "am-6.0" do
  gem "activerecord", "~> 6.0.0"
  gem "sqlite3",    "~> 1.4.0"     if ENV["DB"] == "" || ENV["DB"] == "sqlite"
  gem "mysql2",     "~> 0.5.2"     if ENV["DB"] == "mysql"
  gem "pg",         "~> 1.0.0"     if ENV["DB"] == "postgres"
end

# frozen_string_literal: true

# Specify here only version constraints that differ from
# `active_validation.gemspec`.
#
# > The dependencies in your Appraisals file are combined with dependencies in
# > your Gemfile, so you don't need to repeat anything that's the same for each
# > appraisal. If something is specified in both the Gemfile and an appraisal,
# > the version from the appraisal takes precedence.
# > https://github.com/thoughtbot/appraisal

appraise "am-4.2" do
  gem "activerecord", "~> 4.2.10"
  gem "database_cleaner", "~> 1.6"

  # not compatible with mysql2 0.5
  # https://github.com/brianmario/mysql2/issues/950#issuecomment-376259151
  gem "mysql2", "~> 0.4.10"

  # not compatible with pg 1.0.0
  gem "pg", "~> 0.21.0"

  # TODO: Drop Rails 4.2?

  # TODO: Add mongoid
end

appraise "am-5.0" do
  gem "activerecord", "~> 5.0.0"
  # TODO: Add mongoid
end

appraise "am-5.1" do
  gem "activerecord", "~> 5.1.0"
  # TODO: Add mongoid
end

appraise "am-5.2" do
  gem "activerecord", "~> 5.2.0"
  # TODO: Add mongoid
end

appraise "am-6.0" do
  # TODO: Use actual version number once 6.0 final is released
  gem "activerecord", "~> 6.0.0.beta1"
  # TODO: Add mongoid
end

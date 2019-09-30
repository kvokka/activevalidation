# ActiveValidation

[![Version               ][rubygems_badge]][rubygems]
[![Build Status          ][travisci_badge]][travisci]
[![Codacy Badge          ][codacy_badge]][codacy]
[![Reviewed by Hound     ][hound_badge]][hound]
[![Maintainability       ][codeclimate_badge]][codeclimate]

Validations on steroids. Allows to group validations with versions and
allow to manage validations of the records.

With `ActiveValidation` instead of storing all validations hardcoded
in the Model, you can store them in the database. Manifests are lazy loaded
once, so it does not affect the performance.

## Require

Ruby 2.4+
ActiveModel ~> 5.0

Supported ORM:

* ActiveRecord ~> 5.0

## Overview

The gem allows to store validations for different versions of the records.
Validation versions are stored in the selected plugin (for example DB, but
it is possible to save it in any sort of storage). Each record belongs to
`ActiveValidation::Manifest` which holds general information about
the validation, including `name`, `version` and `id`. Assumed, that
`ActiveValidation::Manifest`'s with the same version are compatible and share
the same validation methods. Folder structure example for model `MyModelName`:

```
.
└── app
    └── models
        ├── my_model_name
        │   └── validations
        │       └── v1.rb
        └── my_model_name.rb
```

Validations themselves are stored in `ActiveValidation::Check`, 1 validation
per one record. `ActiveValidation::Manifest` has many `ActiveValidation::Check`'s.

`ActiveValidation::Manifest` and `ActiveValidation::Check` records are immutable
by design.

It is assumed that inside one version manifests are compatible. Verifier version
is a border between new version and the existed one, which allows co-existing of
both versions for some time.

To control `ActiveValidation::Manifest`'s there is `ActiveValidation::Verifier`
class. Each model with activated `ActiveValidation` has one corresponding
`ActiveValidation::Verifier` instance (which can easily taken with
`MyModelName.active_validation` method). Through this instance user can add or find
Minifest.


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'active_validation'
```

Also will be required create dependent tables in the migration.

#### ActiveRecord

```bash
  create_table :active_validation_manifests do |t|
	t.string   :name
	t.string   :version
	t.string   :base_klass

	t.datetime :created_at
  end

  create_table :active_validation_checks do |t|
	t.integer    :manifest_id
	t.string     :type
	t.string     :argument

	t.json       :options

	t.datetime   :created_at
  end
```

## Quick start


### Initial configuration

```ruby
ActiveValidation.configuration do |c|
  c.orm_adapter = :active_record
end

# app/models/foo
class Foo < ActiveRecord::Base
  active_validation

#  active_validation do |verifier|          # this is a form with optional block
# 	verifier.manifest = some_manifest       # lock manifest
# 	verifier.version = 42 			        # lock version
# 	verifier.orm_adapter = :active_record	# ORM adapter name
#  end
end
```

The usage described [in special spec][readme-spec], and it is always up-to-date.

## Configuration

You can manage default values with the configuration:

```ruby

ActiveValidation.configuration do |c|
  c.manifest_name_formatter # You can set custom manifest name generator, see lib/active_validation/formatters/manifest_name_formatter.rb

  c.validation_context_formatter # You can set custom validation context generator, see lib/active_validation/formatters/validation_context_formatter.rb

  c.orm_adapter # currently supported `active_record`

  c.verifier_defaults do |v|
    v.validations_module_name # folder with validations versions, default: "Validations"

	v.failed_attempt_retry_time # Rate limiter for check of missing Manifest, default: `1 day`
  end
end
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the
[MIT License][mit-licence-link].

[rubygems_badge]: http://img.shields.io/gem/v/activevalidation.svg
[rubygems]: https://rubygems.org/gems/activevalidation
[travisci_badge]: https://travis-ci.org/kvokka/active_validation.svg?branch=master
[travisci]: https://travis-ci.org/kvokka/active_validation
[codacy_badge]: https://api.codacy.com/project/badge/Grade/687bcb63afb74686b3acdd0b8cbaf2cf
[codacy]: https://www.codacy.com/manual/kvokka/activevalidation?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=kvokka/activevalidation&amp;utm_campaign=Badge_Grade
[hound_badge]: https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg
[hound]: https://houndci.com
[codeclimate_badge]: https://api.codeclimate.com/v1/badges/53dc9ce7ec0b94570044/maintainability
[codeclimate]: https://codeclimate.com/github/kvokka/activevalidation/maintainability

[readme-spec]: https://github.com/kvokka/activevalidation/blob/master/spec/active_validation/orm_plugins/active_record_plugin/readme_spec.rb

[mit-licence-link]: http://opensource.org/licenses/MIT

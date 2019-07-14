# ActiveValidation
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'active_validation'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install active_validation
```

```bash
bundle exec rake active_validation:install
bundle exec rake active_record:active_validation
```

## Naming conventions

* method suffix `_klass` assumes, that the the method returns an object with
  the name, which can be converted to `Class`, like `String` or `Symbol`, or
  even `Class` itself.
* method suffix `_class` assumes, that the method returns `Class`

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

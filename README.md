# Read2ref

A gem for generating Puppet Strings-like comments in Supported Modules

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'read2ref'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install read2ref

## Usage

Currently, this can be run as a script with two arguments:
1. Path to the module's README
2. Glob for the modules manifests (don't forget to escape asterisks)

```shell
ruby lib/read2ref.rb path/to/readme glob/for/manifests/\*/\*\*
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eputnam/read2ref.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

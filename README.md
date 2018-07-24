# 🔗 Linked

[![Gem Version](https://badge.fury.io/rb/linked.svg)](https://badge.fury.io/rb/linked)
[![Build Status](https://travis-ci.org/seblindberg/ruby-linked.svg?branch=master)](https://travis-ci.org/seblindberg/ruby-linked)
[![Coverage Status](https://coveralls.io/repos/github/seblindberg/ruby-linked/badge.svg?branch=master)](https://coveralls.io/github/seblindberg/ruby-linked?branch=master)
[![Inline docs](http://inch-ci.org/github/seblindberg/ruby-linked.svg?branch=master)](http://inch-ci.org/github/seblindberg/ruby-linked)

Yet another Linked List implementation for Ruby (hence the somewhat awkward name).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'linked'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install linked

## Usage

A basic use case is show below. For more details, for now, see the docs.

```ruby
require 'linked'

# Create a list
list = Linked::List.new

# Append values
list << :value
list << 'value'

# Or create list items manually
item = Linked::Item.new 42
list.unshift item

# Remove items with #pop and #shift
list.pop.value # => 'value'

# The list behaves much like an Array
list.count # => 2
list.map(&:value) # => [42, :value]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/seblindberg/ruby-linked.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


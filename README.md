# Tou

`Tou`, short for **Time-Ordered-UUID**, is a time-ordered unique identifier scheme. It produces bytes which are compatible with UUIDv4 - the most common UUID format at the moment. While it looks identical to a usual UUIDv4 and will be accepted by all the systems that accept those UUIDs, it has a number of useful properties:

* It starts with the current number of microseconds, packed in big-endian byte order. This means that the UUIDs will sort by byte value in time-ascending order
* It uses 7 bytes of the whole number of microseconds out of 8, giving enough capacity until year 4253
* The rest of the UUID is filled with random bits
* The UUID still has the correct version (4) and variant (1) to be recognized as a UUIDv4

The usage of such UUIDs has some neat properties:

* They sort better in databases using bytes for UUID storage. Iterative SELECTs on large datasets will be much more pleasant.
* They will likely compose into more efficient B-trees in database indexes
* They sort chronologically, allowing for some They sort better in databases using bytes for UUID storage. Iterative SELECTs on large datasets will be much more pleasant.
* The timestamp can be reconstructed from the UUID, and stays relatively precise

## Usage

```ruby
Tou.uuid #=> "061a417b-0e60-4009-9822-72d241ef27d6"
```

Not much to it, really.

## Layout in storage/memory

The Tou is laid out as follows (in its byte representation):

```
| 0 | 1 | 2 | 3 | 4 | 5 |    6    |      7     |     8     | 9 | 10 | 11 | 12 | 13 | 14 | 15 |
|           µs          |4   |   µs      | rnd |10|               rnd                        |
```

To generate a Tou:

```
Take the whole number of microseconds since epoch, encode it as a big-endian unsigned long
Remove the first byte of the encoded value
Fill the rest of the 16 bytes with random bits
Shift the last 4 bits of the timestamp of byte 6 right by 4 bits, to make space for the UUID version
Overwrite the 4 bits where the version is supposed to be located with `100` (for "4")
Overwrite 2 bits of byte 8 when 0-based with 10 for variant
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tou'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install tou


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cheddar-me/tou. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/cheddar-me/tou/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tou project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cheddar-me/tou/blob/master/CODE_OF_CONDUCT.md).

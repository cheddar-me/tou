# Tou

`Tou`, short for **Time-Ordered-UUID**, is a time-ordered unique identifier scheme. It produces bytes which are compatible with UUIDv4 - the most common UUID format at the moment. While it looks identical to a usual UUIDv4 and will be accepted by all the systems that accept those UUIDs, it has a number of useful properties:

* It starts with the current number of microseconds, packed in network byte order. This means that the UUIDs will sort by byte value in time-ascending order
* It uses 7 bytes of the whole number of microseconds out of 8, giving enough capacity until year 4253
* The rest of the UUID is filled with random bits
* The UUID still has the correct version (4) and variant (1) to be recognized as a UUIDv4

The usage of such UUIDs has some neat properties:

* They sort better in databases using bytes for UUID storage. Iterative SELECTs on large datasets will be much more pleasant.
* They will likely compose into more efficient B-trees in database indexes
* They sort chronologically
* The timestamp can be reconstructed from the UUID, and stays relatively precise
* Any system that accepts UUIDv4 identifiers will also accept Tou identifiers
* ...which means that you do not need, say, Postgres extensions to use UUIDv7

## Usage

```ruby
Tou.uuid #=> "061a417b-0e60-4009-9822-72d241ef27d6"
```

Not much to it, really.

## Spec, layout in storage/memory

The Tou is laid out as follows (in its byte representation):

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                               mus                             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|          mus                  |  ver  |  mus  |   random      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|var|                       random                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                           random                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+


mus:
   56-bit big-endian unsigned number of the Unix Epoch timestamp in
   microseconds. Occupies 48 bits (0 through 47 in octets 0-5) and
   4 bits (53 through 57 in octet 6).

ver:
   The 4-bit version field as defined by Section 4.2 of RFC9562,
   set to 0b0100 (4). Occupies bits 48 through 52.

random:
   The 70 bits of pseudorandom data to provide uniqueness as
   per Section 6.9 of RFC9562 and/or an optional counter to guarantee
   additional monotonicity as per Section 6.2 of RFC9562. 
   Occupies bits 49 through 63 and 66 through 127 of
   octets 7 to 15 

var:
   The 2-bit variant field as defined by Section 4.1 of RFC9562,
   set to 0b10. Occupies bits 64 and 65 of octet 8.

```

Compare this to the UUIDv4 layout:

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                           random_a                            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|          random_a             |  ver  |       random_b        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|var|                       random_c                            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                           random_c                            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
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

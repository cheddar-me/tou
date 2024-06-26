require "tou/version"
require "securerandom"

# A generator for time-ordered UUIDs
module Tou
  autoload :VERSION, __dir__ + "/tou/version.rb"
  autoload :Generator, __dir__ + "/tou/generator.rb"

  # Generates the bag of 16 bytes with UUID in binary form. This is not the
  # canonical representation but can be converted into one.
  #
  # @param random[#bytes] Source of randomness. Normally SecureRandom will be used, but it can be
  #   replaced by a mock or a `Random` object with a known seed, for testing or speed.
  # @param time[#to_f] A time value that is convertible to a floating-point number of seconds since epoch
  # @return [String] in binary encoding
  def self.uuid_bytes(random: SecureRandom, time: Time.now)
    # Use microseconds for the timestamp
    epoch_micros = (time.to_f * 1_000_000).round
    # Encode an 8-byte unsigned big-endian uint, and skip the first byte since it's 0, so we're left with 7 bytes.
    # This gives us sufficient timestamp resolution to last us into year
    # This will limit our timestamp to the year 4307.
    # Q> : 64 bit unsigned big-endian int
    # We want more significant bytes first for better sorting in Postgres
    epoch_micros_unsigned_uint_bytes = [epoch_micros].pack("Q>")[1..]
    ts_bytes = epoch_micros_unsigned_uint_bytes

    # Use the remaining bytes for randomness
    byte_str = ts_bytes + random.bytes(16 - ts_bytes.bytesize)

    # This last part encodes the version, the timecode and the variant.
    # To prevent we have a variant, 4 bits of random and then the timecode I move up the timecode 4 bits.
    # We end up with: 4bit variant - 8bit timecode - 4bit random from original byte string, hence 2 bytes in total.
    #
    # V4 random UUIDs use 4 bits to indicate a version and another 2-3 bits to indicate a variant.
    # Most V4s (including these ones) are variant 1, which is 2 bits.
    version = "4" # version 4, 4 bits.
    timepart = ts_bytes[-1].unpack1("H*") # last byte of timecode (ts_bytes) as hex, 8 bits.
    rest = byte_str[7].unpack1("h") # last 4 bits of 7th byte as hex.

    # Our uuid with encoded timestamp will look something like this 16 bytes in total:
    # ts = timestamp byte
    # rnd = random byte
    # |ts| ts, ts, ts, ts, ts, version(4bits) + first half ts(4bits), last half of ts(4bits) + rnd, variant(2bits) + rnd, rnd, rnd, rnd, rnd, rnd, rnd, rnd]
    byte_str_part_with_time_and_variant = [version + timepart + rest].pack("H*")

    byte_str.setbyte(6, byte_str_part_with_time_and_variant.getbyte(0))
    byte_str.setbyte(7, byte_str_part_with_time_and_variant.getbyte(1))
    byte_str.setbyte(8, (byte_str.getbyte(8) & 0x3f) | 0x80) # variant 1 (10 binary)

    byte_str
  end

  # Generates the bag of 16 bytes with UUID in binary form. This the
  # canonical representation but can be converted into one.
  #
  # @param random[#bytes] Source of randomness. Normally SecureRandom will be used, but it can be
  #   replaced by a mock or a `Random` object with a known seed, for testing or speed.
  # @param time[#to_f] A time value that is convertible to a floating-point number of seconds since epoch
  # @return [String] in binary encoding
  def self.uuid(**params_for_uuid_bytes)
    # N : 32 bit unsigned int
    # n : 16 bit unsigned int
    # This will separate the whole random bytestring into a couple groups
    # (as various sized integers) that match the uuid group size
    # so [32bit int, 16bit int, 16bit int, 16bit int, 16bit int, 32bit int]
    # Which then can be shown in hex into the string literal to make up the final uuid.
    ary = uuid_bytes(**params_for_uuid_bytes).unpack("NnnnnN")
    # format in hex notation with dashes
    "%08x-%04x-%04x-%04x-%04x%08x" % ary
  end
end

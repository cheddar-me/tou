require "tou/version"

# Create a 16 byte random bytestring with the first 6 bytes having the current timestamp encoded
# Usage:
# uuid_bytes_to_s(generate_time_ordered_uuid_bytes)
module TimeEncodedUUID
  def self.generate_time_ordered_uuid_bytes
    # multiply by 1_000_000 so we have enough resolution to make the timestamp increment for every transaction
    epoch_micros = (Time.now.to_f * 1_000_000).round
    # Encode an 8-byte unsigned big-endian uint, and skip the first byte since it's 0, so we're left with 7 bytes.
    # This will limit our timestamp to the year 4307.
    # Q> : 64 bit unsigned big-endian int
    epoch_micros_unsigned_uint_bytes = [epoch_micros].pack("Q>")[1..]
    ts_bytes = epoch_micros_unsigned_uint_bytes

    # Geneate the remaining 10 bytes randomly
    byte_str = ts_bytes + SecureRandom.random_bytes(16 - ts_bytes.bytesize)

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

  # Format a 16 byte (random) bytestring to the uuid style we know
  def self.uuid_bytes_to_s(uuid_bytes_str)
    # N : 32 bit unsigned int
    # n : 16 bit unsigned int
    # This will separate the whole random bytestring into a couple groups
    # (as various sized integers) that match the uuid group size
    # so [32bit int, 16bit int, 16bit int, 16bit int, 16bit int, 32bit int]
    # Which then can be shown in hex into the string literal to make up the final uuid.
    ary = uuid_bytes_str.unpack("NnnnnN")
    # format in hex notation with dashes
    "%08x-%04x-%04x-%04x-%04x%08x" % ary
  end

  def self.generate_uuid_v4
    uuid_bytes_to_s(generate_time_ordered_uuid_bytes)
  end
end

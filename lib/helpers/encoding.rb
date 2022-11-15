require_relative "hash"

module Helpers
  module Encoding
    BASE58_ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    # convert a number to a byte string
    def self.to_bytes(integer, bytes, endianness = "big")
      byte_array = [0] * bytes
      integer.digits(256).each_with_index do |byte, index|
        byte_array[index] = byte
      end
      byte_array.reverse! if endianness == "big"
      byte_array.pack("c*")
    end

    # convert a byte string to a number
    def self.from_bytes(bytes, endianness = "big")
      bytes = bytes.unpack("C*")
      bytes.reverse! if endianness == "big"
      bytes.map.with_index { |byte, index| byte * 256**index }.sum
    end

    def self.from_hex_to_bytes(hex)
      [hex.strip].pack("H*")
    end

    def self.from_bytes_to_hex(bytes)
      bytes.unpack1("H*")
    end

    def self.from_hex_to_int(hex)
      from_bytes(from_hex_to_bytes(hex))
    end

    def self.base58_encode(str)
      count = 0
      str.each_char { |c| count += 1 if c == 0 }
      prefix = "1" * count

      num = from_bytes(str)
      result = ""
      while num > 0
        num, mod = num.divmod(58)
        result = BASE58_ALPHABET[mod] + result
      end

      prefix + result
    end

    def self.decode_base58(str)
      num = 0
      str.each_char do |char|
        num *= 58
        num += BASE58_ALPHABET.index(char)
      end
      num
    end

    def self.base58_encode_checksum(bytes)
      base58_encode(bytes + Helpers::Hash.hash256(bytes).slice(0, 4))
    end

    def self.encode_varint(integer)
      if integer < 0xfd # 253
        to_bytes(integer, 1)
      elsif integer < 0x10000 # 65536
        to_bytes(0xfd, 1) + to_bytes(integer, 2, "little")
      elsif integer < 0x100000000 # 4294967296
        to_bytes(0xfe, 1) + to_bytes(integer, 4, "little")
      elsif integer < 0x10000000000000000 # 18446744073709551616
        to_bytes(0xff, 1) + to_bytes(integer, 8, "little")
      else
        raise "Integer too large"
      end
    end

    def self.read_varint(stream)
      io = Helpers::IO.new(stream)
      io.read_varint
    end
  end
end

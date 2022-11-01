require_relative "hash"

module Helpers
  module Encoding
    BASE58_ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    def to_bytes(integer, bytes, endianness = "big")
      byte_array = [0] * bytes
      integer.digits(256).each_with_index do |byte, index|
        byte_array[index] = byte
      end
      byte_array.reverse! if endianness == "big"
      byte_array.pack("c*")
    end

    def from_bytes(bytes, endianness = "big")
      bytes = bytes.unpack("C*")
      bytes.reverse! if endianness == "big"
      bytes.map.with_index { |byte, index| byte * 256**index }.sum
    end

    def from_hex_to_bytes(hex)
      [hex.strip].pack("H*")
    end

    def base58_encode(str)
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

    def base58_encode_checksum(bytes)
      base58_encode(bytes + Helpers::Hash.hash256(bytes).slice(0, 4))
    end

    def encode_varint(integer)
      if integer < 0xfd
        to_bytes(integer, 1)
      elsif integer < 0x10000
        to_bytes(0xfd, 1) + to_bytes(integer, 2)
      elsif integer < 0x100000000
        to_bytes(0xfe, 1) + to_bytes(integer, 4)
      elsif integer < 0x10000000000000000
        to_bytes(0xff, 1) + to_bytes(integer, 8)
      else
        raise "Integer too large"
      end
    end
  end
end

require_relative "hash"

module Helpers
  module Encoding
    BASE58_ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    # after writing this i learnt that it's better to define methods
    # as instance methods and then using extend to make them class methods,
    # but i'll leave it like this anyways to avoid the refactoring needed to change it
    def self.included(base)
      # remove included from methods
      class_methods = methods(false).reject { |m| m == :included }
      class_methods.each do |method|
        # define instance method to be able to call class methods as instance methods
        base.define_method(method) do |*args|
          Helpers::Encoding.send(method, *args)
        end
      end
    end

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

    # convert a hexadecimal number into a byte string
    def self.from_hex_to_bytes(hex)
      [hex.strip].pack("H*")
    end

    def self.from_bytes_to_hex(bytes)
      bytes.unpack1("H*")
    end

    def self.from_hex_to_int(hex)
      from_bytes(from_hex_to_bytes(hex))
    end

    def self.from_int_to_hex(integer, bytes, endianness = "big")
      from_bytes_to_hex(to_bytes(integer, bytes, endianness))
    end

    def self.string_to_bytes(string)
      bytes = string.bytes.map { |byte| byte.to_s(16).rjust(2, "0") }.join
    end

    def self.bytes_to_string(bytes, endiannes = "big")
      if endiannes == "big"
        bytes.scan(/../).map(&:hex).pack("c*")
      else
        bytes.scan(/../).map(&:hex).reverse.pack("c*")
      end
    end

    def self.base58_encode(str)
      count = 0
      str.each_char { |c| count += 1 if c == "\x00" }
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

    def self.bit_field_to_bytes(bit_field)
      raise EncodingError, "bit_field's length is not divisible by 8" if bit_field.length % 8 != 0

      result = [0] * (bit_field.length / 8)
      bit_field.each_with_index do |bit, index|
        byte_index, bit_index = index.divmod(8)
        result[byte_index] |= 1 << bit_index unless bit.zero?
      end
      result.pack("c*")
    end
  end
end

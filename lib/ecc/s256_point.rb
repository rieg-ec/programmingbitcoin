require_relative "point"
require_relative "s256_field"
require_relative "secp256k1_constants"
require_relative "../helpers/encoding"
require_relative "../helpers/hash"

module ECC
  ##
  # S256Point represents a point on the secp256k1 curve.
  # specifically, it is used to represent public keys.
  class S256Point < Point
    def initialize(x, y, _a = nil, _b = nil)
      a = S256Field.new(Secp256k1Constants::A)
      b = S256Field.new(Secp256k1Constants::B)

      if x.is_a? Integer
        x = S256Field.new(x)
        y = S256Field.new(y)
      end

      super(x, y, a, b)
    end

    # the generator point for secp256k1
    G = S256Point.new(Secp256k1Constants::G_X, Secp256k1Constants::G_Y)

    def self.h160_to_p2pkh_address(h160, testnet: false)
      prefix = testnet ? "\x6f" : "\x00"
      Helpers::Encoding.base58_encode_checksum(prefix + h160)
    end

    def self.h160_to_p2sh_address(h160, testnet: false)
      prefix = testnet ? "\xc4" : "\x05"
      Helpers::Encoding.base58_encode_checksum(prefix + h160)
    end

    def address(compressed: true, testnet: false)
      prefix = testnet ? "\x6f" : "\x00"
      Helpers::Encoding.base58_encode_checksum(
        prefix + hash160(compressed: compressed)
      )
    end

    # returns the bitcoin address for the given
    # base58 encoded network prefix + address + checksum
    def self.decode_address(base58_address)
      address = Helpers::Encoding.decode_base58(base58_address)
      combined = Helpers::Encoding.to_bytes(address, 25)
      # checksum is last 4 bytes
      checksum = combined[-4..-1]
      computed_checksum = Helpers::Hash.hash256(combined[0..-5])[0..3]
      raise "Invalid checksum" unless checksum == computed_checksum

      # network prefix is the first byte
      combined[1..-5]
    end

    def scalar_multiply(num)
      num = num % Secp256k1Constants::N
      super(num)
    end

    # verify that the signature is valid for the given hash.
    # z is the hash256 of the "document" being signed.
    def verify?(z, sig)
      s_inv = sig.s.pow(Secp256k1Constants::N - 2, Secp256k1Constants::N)
      u = z * s_inv % Secp256k1Constants::N
      v = sig.r * s_inv % Secp256k1Constants::N
      target = u * self.class::G + v * self
      target.x.num == sig.r
    end

    def sec(compressed: true)
      if compressed
        prefix = @y.even? ? "\x02" : "\x03"
        return prefix + Helpers::Encoding.to_bytes(@x.num, 32)
      end

      Helpers::Encoding.to_bytes(4, 1) +
        Helpers::Encoding.to_bytes(@x.num, 32) +
        Helpers::Encoding.to_bytes(@y.num, 32)
    end

    def self.parse(sec_bin)
      # uncompressed format
      if sec_bin[0] == "\x04"
        x = Helpers::Encoding.from_bytes(sec_bin.slice(1, 32))
        y = Helpers::Encoding.from_bytes(sec_bin.slice(33, 32))

        return new(x, y)
      end

      # compressed format
      x = S256Field.new(Helpers::Encoding.from_bytes(sec_bin[1..]))
      y_sq = x**3 + S256Field.new(Secp256k1Constants::B)
      y = y_sq.sqrt

      if y.even?
        y_even = y
        y_odd = S256Field.new(Secp256k1Constants::P - y.num)
      else
        y_even = S256Field.new(Secp256k1Constants::P - y.num)
        y_odd = y
      end

      # \x02 prefix byte means y is even, \x03 means y is odd
      sec_bin[0] == "\x02" ? new(x, y_even) : new(x, y_odd)
    end

    private

    def hash160(compressed: true)
      Helpers::Hash.hash160(sec(compressed: compressed))
    end
  end
end

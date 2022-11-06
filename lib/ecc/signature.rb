require_relative "point"
require_relative "s256_field"
require_relative "secp256k1_constants"
require_relative "../helpers/encoding"

module ECC
  class Signature
    attr_reader :r, :s

    def initialize(r, s)
      @r = r
      @s = s
    end

    def to_s
      "Signature(#{@r}, #{@s})"
    end

    def der
      rbin = formatted_to_der(@r)
      sbin = formatted_to_der(@s)

      rbin_length_b = Helpers::Encoding.to_bytes(rbin.length, 1)
      sbin_length_b = Helpers::Encoding.to_bytes(sbin.length, 1)

      result = "\x02#{rbin_length_b}#{rbin}\x02#{sbin_length_b}#{sbin}"

      "\x30#{Helpers::Encoding.to_bytes(result.length, 1)}#{result}"
    end

    # parses a DER signature
    def self.parse(der)
      # first byte is 0x30
      raise "bad der: #{der}" if der[0] != "\x30"

      # next byte is the length of the signature
      length = der[1].unpack1("C")
      # next length bytes are the signature
      signature = der[2..length + 1]
      # first byte is market byte 0x02
      raise "Signature not in DER format" if signature[0] != "\x02"

      # next byte is the length of r
      r_length = signature[1].unpack1("C")
      # next r_length bytes are r
      r = Helpers::Encoding.from_bytes(signature[2, r_length])
      # next byte is marker byte 0x02
      raise "Signature not in DER format" if signature[r_length + 2] != "\x02"

      # next byte is the length of s
      s_length = signature[r_length + 3].unpack1("C")
      # next s_length bytes are s
      s = Helpers::Encoding.from_bytes(signature[r_length + 4, s_length])

      new(r, s)
    end

    private

    def formatted_to_der(elem)
      elem = Helpers::Encoding.to_bytes(elem, 32)
      elem = elem.reverse.chomp("\x00").reverse
      # no idea why this doesn't work:
      # elem = "\x00#{elem}" if elem[0].unpack1("C") & 0x80
      # elem
      elem[0].unpack1("C") > 128 ? "\x00#{elem}" : elem
    end
  end
end

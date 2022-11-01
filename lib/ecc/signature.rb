require_relative "point"
require_relative "s256_field"
require_relative "secp256k1_constants"
require_relative "../helpers/encoding"

module ECC
  class Signature
    include Helpers::Encoding

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
      result = "\x02#{to_bytes(rbin.length, 1)}#{rbin}\x02#{to_bytes(sbin.length, 1)}#{sbin}"

      "\x30#{to_bytes(result.length, 1)}#{result}"
    end

    def formatted_to_der(elem)
      elem = to_bytes(elem, 32)
      elem = elem.reverse.chomp("\x00").reverse
      # no idea why this doesn't work:
      # elem = "\x00#{elem}" if elem[0].unpack1("C") & 0x80
      # elem
      elem[0].unpack1("C") > 128 ? "\x00#{elem}" : elem
    end
  end
end

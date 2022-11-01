module Helpers
  module Script
    OP_CODES = {
      118 => :op_dup,
      169 => :op_hash160,
      170 => :op_hash256
    }

    # @TODO specify num type
    # @TODO test this
    def encode_num(num)
      return "\x00" if num == 0

      result = ""
      negative = num < 0
      num = num.abs
      while num > 0
        result << (num & 0xff).chr
        num >>= 8
      end
      if result.last == "\x80"
        result << (negative ? "\x80" : "\x00")
      elsif negative
        result[-1] = (result.last.ord | 0x80).chr
      end

      result
    end

    # @TODO specify num type
    # @TODO test this
    def decode_num(num)
      return 0 if num == "\x00"

      big_endian = num.reverse

      if big_endian.last.ord & 0x80 == 0x80
        negative = true
        result = (big_endian.first.ord & 0x7f).chr
      else
        negative = false
        result = big_endian.first
      end

      result << big_endian[1..-1]

      negative ? -result : result
    end

    def op_0
      @stack << Helpers.encode_num(0)
      true
    end

    def op_dup
      return false if @stack.length < 1

      @stack << @stack.last
      true
    end

    def op_hash256
      return false if @stack.length < 1

      @stack << Helpers::Hash.hash256(@stack.pop)
      true
    end

    def op_hash160
      return false if @stack.length < 1

      @stack << Helpers::Hash.hash160(@stack.pop)
      true
    end

    # z is the hash256 of the "document" being signed.
    def op_checksig
      return false if @stack.length < 2

      pub_key = ECC::S256Point.new(@stack.pop)
      sig = ECC::Signature.new(@stack.pop)

      @stack << (pub_key.verify?(@z, sig) ? 1 : 0)

      true
    end

    def op_mul
      return false if @stack.length < 2

      a = Helpers::Encoding.decode_num(@stack.pop)
      b = Helpers::Encoding.decode_num(@stack.pop)

      @stack << Helpers::Encoding.encode_num(a * b)

      true
    end
  end
end

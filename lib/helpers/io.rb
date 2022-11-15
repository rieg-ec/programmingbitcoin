require "forwardable"

module Helpers
  class IO
    extend Forwardable

    def_delegators :@io, :read, :rewind

    def initialize(io)
      @io = io
      @io = StringIO.new(io) if io.is_a?(String)
    end

    def read_le(length)
      @io.read(length).reverse
    end

    def read_int8
      @io.read(1).unpack1("C")
    end

    def read_le_int16
      @io.read(2).unpack1("v")
    end

    def read_le_int32
      @io.read(4).unpack1("V")
    end

    def read_le_int64
      @io.read(8).unpack1("Q<")
    end

    def read_varint
      r = @io.read(1).unpack1("C")

      case r
      when 0xfd # 253
        read_le_int16
      when 0xfe # 254
        read_le_int32
      when 0xff # 255
        read_le_int64
      else
        r
      end
    end
  end
end

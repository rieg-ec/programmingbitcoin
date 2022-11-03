require_relative "../helpers/hash"
require_relative "../helpers/encoding"
require_relative "../helpers/script"

module Bitcoin
  class Script
    include Helpers::Encoding
    include Helpers::Script

    attr_reader :opcodes

    def initialize(opcodes = [])
      @opcodes = opcodes
      @stack = []
    end

    def +(other)
      self.class.new(@opcodes + other.opcodes)
    end

    def self.parse(io)
      length = io.read_varint
      opcodes = []
      count = 0
      while count < length
        opcode = io.read_le_int8
        count += 1
        if opcode >= 1 && opcode <= 75
          opcodes.append(io.read(opcode))
          count += opcode
        elsif opcode == 76
          length = io.read_le_int8
          opcodes.append(io.read(length))
          count += length + 1
        elsif opcode == 77
          length = io.read_le_int16
          opcodes.append(io.read(length))
          count += length + 2
        else
          opcodes << opcode
        end
      end

      raise "script length mismatch" if count != length

      new(opcodes)
    end

    def serialize
      result = raw_serialize
      length = encode_varint(result.length)
      "#{length}#{result}"
    end

    # evaluate the script. returns true if the script is valid.
    # z is the hash of the transaction
    def evaluate(z)
      opcodes = @opcodes.dup
      @stack = []
      @alternative_stack = []
      @z = z
      while opcodes.length > 0
        opcode = opcodes.shift
        if Helpers::Script.valid_opcode?(opcode)
          if Helpers::Encoding.implemented_opcode?(opcode)
            send(Helpers::Script.opcode_method[opcode])
          else
            raise "invalid opcode: #{opcode}"
          end
        else
          @stack << opcode
        end
      end

      return false if @stack.length == 0 || @stack.last == "\x00"

      true
    end

    private

    def raw_serialize
      result = ""
      @opcodes.each do |opcode|
        if opcode.is_a?(Integer)
          result << to_bytes(opcode, 1, "little")
        else
          if opcode.length < 75
            result << to_bytes(opcode.length, 1, "little")
          elsif opcode.length < 256
            result << "\x4c"
            result << to_bytes(opcode.length, 1, "little")
          elsif opcode.length <= 520
            result << "\x4d"
            result << to_bytes(opcode.length, 2, "little")
          else
            raise "invalid opcode"
          end

          result << opcode
        end
      end

      result
    end
  end
end

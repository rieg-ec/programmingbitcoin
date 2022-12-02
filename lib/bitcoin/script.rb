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

    def to_s
      @opcodes.map do |opcode|
        if opcode.is_a?(Integer)
          Helpers::Script::OP_CODES[opcode]
        else
          Helpers::Encoding.from_bytes_to_hex(opcode)
        end
      end.join(" ")
    end

    def self.parse(io)
      length = io.read_varint
      opcodes = []
      count = 0
      while count < length
        opcode = io.read_int8
        count += 1
        if opcode >= 1 && opcode <= 75
          opcodes.append(io.read(opcode))
          count += opcode
        elsif opcode == 76
          data_length = io.read_int8
          opcodes.append(io.read_le(data_length))
          count += data_length + 1
        elsif opcode == 77
          data_length = io.read_le_int16
          opcodes.append(io.read(data_length))
          count += data_length + 2
        else
          opcodes << opcode
        end
      end

      raise "script length mismatch: count = #{count} and length = #{length}" if count != length

      new(opcodes)
    end

    def serialize
      result = raw_serialize
      length = Helpers::Encoding.encode_varint(result.length)
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
          return evaluate_redeem_script(opcode, opcodes) if p2sh?
        end
      end

      return false if @stack.length == 0 || @stack.last == "\x00"

      true
    end

    def self.p2pkh_script(hash160)
      # OP_DUP OP_HASH160 <hash160> OP_EQUALVERIFY OP_CHECKSIG
      new([118, 169, hash160, 136, 172])
    end

    def p2sh?
      @stack.length == 3 &&
        @stack[0] == "\xa9" &&
        @stack[1].length == 20 &&
        @stack[2] == "\x87"
    end

    private

    def evaluate_redeem_script(opcode, opcodes)
      @stack.pop # OP_HASH160
      h160 = @stack.pop # public key
      @stack.pop # OP_EQUAL
      return false unless op_hash160

      @stack << h160
      return false unless op_equal
      return false unless op_verify

      redeem_script = Helpers::Encoding.encode_varint(@stack.length) + opcode
      stream = Helpers::IO.new(redeem_script)
      opcodes << self.class.parse(stream).opcodes
      true
    end

    def raw_serialize
      result = ""
      @opcodes.each do |opcode|
        if opcode.is_a?(Integer)
          result << Helpers::Encoding.to_bytes(opcode, 1)
        else
          if opcode.length < 75
            result << Helpers::Encoding.to_bytes(opcode.length, 1)
          elsif opcode.length < 256
            # OP_PUSHDATA1 + length
            result << "\x4c"
            result << Helpers::Encoding.to_bytes(opcode.length, 1)
          elsif opcode.length <= 520
            # OP_PUSHDATA2 + length
            result << "\x4d"
            result << Helpers::Encoding.to_bytes(opcode.length, 2, "little")
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

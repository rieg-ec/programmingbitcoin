module Bitcoin
  class Block
    def initialize(version:, prev_block:, merkle_root:, timestamp:, bits:, nonce:)
      @version = version
      @prev_block = prev_block
      @merkle_root = merkle_root
      @timestamp = timestamp
      @bits = bits
      @nonce = nonce
    end

    def self.target(bytestring)
      exponent = Helpers::Encoding.from_bytes(bytestring[-1])
      coefficient = Helpers::Encoding.from_bytes(bytestring[0..-2], "little")
      coefficient * 256**(exponent - 3)
    end

    def self.difficulty(bits)
      0xffff * 256**(0x1d - 3) / target(bits).to_f
    end

    def self.parse(io)
      version = io.read_le_int32
      prev_block = io.read_le(32)
      merkle_root = io.read_le(32)
      timestamp = io.read_le_int32
      bits = io.read_le_int32
      nonce = io.read_le_int32

      new(
        version: version,
        prev_block: prev_block,
        merkle_root: merkle_root,
        timestamp: timestamp,
        bits: bits,
        nonce: nonce
      )
    end

    def serialize
      result = Helpers::Encoding.to_bytes(@version, 4, "little")
      result << @prev_block.reverse
      result << @merkle_root.reverse
      result << Helpers::Encoding.to_bytes(@timestamp, 4, "little")
      result << Helpers::Encoding.to_bytes(@bits, 4, "little")
      result << Helpers::Encoding.to_bytes(@nonce, 4, "little")
      result
    end

    def hash
      Helpers::Hash.hash256(serialize)
    end

    def bip9
      @version >> 29
    end

    def bip91
      (@version >> 4) & 1
    end

    def bip141
      (@version >> 1) & 1
    end

    def difficulty
      0xffff * 256**(0x1d - 3) / bits_to_target.to_f
    end

    def check_pow
      Helpers::Encoding.from_bytes(hash, "little") < target(@bits)
    end
  end
end

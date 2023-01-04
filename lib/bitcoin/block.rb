require_relative "../helpers/encoding"

module Bitcoin
  class Block
    include Helpers::Encoding

    GENESIS_BLOCK = Helpers::Encoding.from_hex_to_bytes("0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a29ab5f49ffff001d1dac2b7c")
    TESTNET_GENESIS_BLOCK = Helpers::Encoding.from_hex_to_bytes("0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4adae5494dffff001d1aa4ae18")
    LOWEST_BITS = Helpers::Encoding.from_hex_to_bytes("ffff001d")

    attr_accessor :version, :prev_block, :merkle_root, :timestamp, :bits, :nonce

    def initialize(
      version:,
      prev_block:,
      merkle_root:,
      timestamp:,
      bits:,
      nonce:,
      tx_hashes: []
    )
      @version = version
      @prev_block = prev_block
      @merkle_root = merkle_root
      @timestamp = timestamp
      @bits = bits
      @nonce = nonce
      @tx_hashes = tx_hashes
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
      bits = io.read(4)
      nonce = io.read(4)

      new(
        version: version,
        prev_block: prev_block,
        merkle_root: merkle_root,
        timestamp: timestamp,
        bits: bits,
        nonce: nonce
      )
    end

    def merkle_root_valid?
      computed_merkle_root = MerkleTree.merkle_root(@tx_hashes.map(&:reverse))
      computed_merkle_root.reverse == @merkle_root
    end

    def serialize
      result = to_bytes(@version, 4, "little")
      result << @prev_block.reverse
      result << @merkle_root.reverse
      result << to_bytes(@timestamp, 4, "little")
      result << @bits
      result << @nonce
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
      0xffff * 256**(0x1d - 3) / target.to_f
    end

    # this method is not tested, may be wrong
    def target
      exponent = Helpers::Encoding.from_bytes(@bits[-1], "little")
      coefficient = Helpers::Encoding.from_bytes(@bits[0..-2], "little")
      coefficient * 256**(exponent - 3)
    end

    def pow_valid?
      Helpers::Encoding.from_bytes(hash, "little") <= target
    end
  end
end

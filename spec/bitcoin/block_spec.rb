require "helpers/encoding"
require "bitcoin/block"
require "helpers/io"

RSpec.describe Bitcoin::Block do
  include Helpers::Encoding

  let(:raw_block_header) do
    from_hex_to_bytes(
      "020000208ec39428b17323fa0ddec8e887b4a7c53b8c0a0a220cfd0000000000000000005b0750fce0a889502d40\
508d39576821155e9c9e3f5c3157f961db38fd8b25be1e77a759e93c0118a4ffd71d"
    )
  end

  let(:block_header) do
    described_class.new(
      version: 0x20000002,
      prev_block: from_hex_to_bytes("000000000000000000fd0c220a0a8c3bc5a7b487e8c8de0dfa2373b12894c38e"),
      merkle_root: from_hex_to_bytes("be258bfd38db61f957315c3f9e9c5e15216857398d50402d5089a8e0fc50075b"),
      timestamp: 0x59a7771e,
      bits: from_hex_to_bytes("e93c0118"),
      nonce: from_hex_to_bytes("a4ffd71d")
    )
  end

  describe "#bits_to_target" do
    bytestring = Helpers::Encoding.from_hex_to_bytes("e93c0118")
    target = Bitcoin::Block.target(bytestring).to_s(16)
    it { expect(target).to eq("13ce9000000000000000000000000000000000000000000") }
  end

  describe "#difficulty" do
    bytestring = Helpers::Encoding.from_hex_to_bytes("e93c0118")
    difficulty = Bitcoin::Block.difficulty(bytestring)
    it { expect(difficulty).to eq(888_171_856_257.3206) }
  end

  describe "#pow_valid?" do
    context "with valid PoW" do
      it { expect(block_header.pow_valid?).to be true }
    end

    context "with invalid PoW" do
      before { block_header.nonce = from_hex_to_bytes("00000000") }

      it { expect(block_header.pow_valid?).to be false }
    end
  end

  describe ".parse" do
    def parse(*args)
      described_class.parse(Helpers::IO.new(*args))
    end

    it "properly parses the version" do
      expect(parse(raw_block_header).version).to eq block_header.version
    end

    it "properly parses the previous block" do
      expect(parse(raw_block_header).prev_block).to eq block_header.prev_block
    end

    it "properly parses the merkle root" do
      expect(parse(raw_block_header).merkle_root).to eq block_header.merkle_root
    end

    it "properly parses the timestamp" do
      expect(parse(raw_block_header).timestamp).to eq block_header.timestamp
    end

    it "properly parses the bits" do
      expect(parse(raw_block_header).bits).to eq block_header.bits
    end

    it "properly parses the nonce" do
      expect(parse(raw_block_header).nonce).to eq block_header.nonce
    end
  end
end

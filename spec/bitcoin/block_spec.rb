require "helpers/encoding"
require "bitcoin/block"

RSpec.describe Bitcoin::Block do
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
end

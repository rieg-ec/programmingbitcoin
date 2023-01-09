require "spec_helper"
require "bitcoin/bloom_filter"
require "helpers/encoding"

RSpec.describe Bitcoin::BloomFilter do
  include Helpers::Encoding

  it_behaves_like "murmur3"

  describe "#filterload" do
    it "returns the proper generic filterload message" do
      bloom_filter = described_class.new(10, 5, 99)
      bloom_filter.add("Hello World")
      bloom_filter.add("Goodbye!")
      expect(bloom_filter.filterload.command).to eq "filterload"
      expect(bloom_filter.filterload.serialize)
        .to eq from_hex_to_bytes("0a4000600a080000010940050000006300000000")
    end
  end
end

require "ecc/s256_point"

RSpec.describe ECC::S256Point do
  let(:element) { described_class.new(7, 11) }

  describe "#verify" do
    let(:e) {}
    let(:z) {}
    let(:k) {}
    let(:z) {}
    let(:z) {}
    let(:z) {}
  end

  describe "#sec" do
    it "returns the binary version of the uncompressed SEC format" do
      pubkey = ECC::PrivateKey.new(5000).point
      sec_bytes_hex = "04ffe558e388852f0120e46af2d1b370f85854a8eb0841811ece0e3e"\
                      "03d282d57c315dc72890a4f10a1481c031b03b351b0dc79901ca18a00cf009dbdb157a1d10"
      expect(pubkey.sec(compressed: false).unpack1("H*")).to eq(sec_bytes_hex)
    end

    it "returns the binary version of the compressed SEC format" do
      pubkey = ECC::PrivateKey.new(5001).point
      sec_bytes_hex = "0357a4f368868a8a6d572991e484e664810ff14c05c0fa023275251151fe0e53d1"
      expect(pubkey.sec(compressed: true).unpack1("H*")).to eq(sec_bytes_hex)
    end
  end

  describe "#self.parse" do
    it "returns a Point object from a uncompressed SEC binary" do
      pubkey = ECC::PrivateKey.new(5001).point
      sec_bytes = pubkey.sec(compressed: false)
      expect(described_class.parse(sec_bytes)).to eq pubkey
    end

    it "returns a Point object from a compressed SEC binary" do
      pubkey = ECC::PrivateKey.new(5001).point
      sec_bytes = pubkey.sec(compressed: true)
      expect(described_class.parse(sec_bytes)).to eq pubkey
    end
  end
end

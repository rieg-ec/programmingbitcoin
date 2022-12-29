require "bitcoin/version_message"
require "helpers/encoding"
require "timecop"

RSpec.describe Bitcoin::VersionMessage do
  include Helpers::Encoding

  def serialized_message_hex
    from_bytes_to_hex(described_class.new.serialize)
  end

  before do
    freezed_time = Time.new(2008, 9, 1, 10, 5, 0, "+00:00")
    Timecop.freeze(freezed_time)
  end

  describe "#serialize" do
    it "serializes version" do
      expect(serialized_message_hex.slice(0, 8)).to(eq("7f110100"))
    end

    it "serializes services" do
      expect(serialized_message_hex.slice(8, 16)).to(eq("0000000000000000"))
    end

    it "serializes timestamp" do
      expect(serialized_message_hex.slice(24, 16)).to(eq("4cbebb4800000000"))
    end

    it "serializes receiver services" do
      expect(serialized_message_hex.slice(40, 16)).to(eq("0000000000000000"))
    end

    it "serializes receiver ip" do
      expect(serialized_message_hex.slice(56, 32)).to(eq("00000000000000000000ffff00000000"))
    end

    it "serializes receiver port" do
      expect(serialized_message_hex.slice(88, 4)).to(eq("208d"))
    end

    it "serializes sender services" do
      expect(serialized_message_hex.slice(92, 16)).to(eq("0000000000000000"))
    end

    it "serializes sender ip" do
      expect(serialized_message_hex.slice(108, 32)).to(eq("00000000000000000000ffff00000000"))
    end

    it "serializes sender port" do
      expect(serialized_message_hex.slice(140, 4)).to(eq("208d"))
    end

    it "serializes nonce" do
      expect(serialized_message_hex.slice(144, 16)).to(eq("0000000000000000"))
    end

    it "serializes user agent" do
      expect(serialized_message_hex.slice(160, 50)).to(
        eq("182f70726f6772616d6d696e67626974636f696e3a302e312f")
      )
    end

    it "serializes latest block" do
      expect(serialized_message_hex.slice(210, 8)).to(eq("00000000"))
    end
  end
end

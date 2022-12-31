# encoding: ascii-8bit

require "bitcoin/network_envelope"
require "helpers/encoding"
require "helpers/io"

RSpec.describe Bitcoin::NetworkEnvelope do
  include Helpers::Encoding

  let(:raw_envelope) { from_hex_to_bytes("f9beb4d976657261636b000000000000000000005df6e0e2") }

  def parse(_raw_envelope)
    described_class.parse(Helpers::IO.new(_raw_envelope))
  end

  describe ".parse" do
    it "properly parses magic hex" do
      expect(parse(raw_envelope).magic).to eq Bitcoin::NetworkEnvelope::MAINNET_MAGIC
    end

    it "properly parses command bytes" do
      expect(parse(raw_envelope).command).to eq "verack"
    end

    it "properly parses payload bytes" do
      expect(parse(raw_envelope).payload).to eq ""
    end
  end

  describe "#serialize" do
    it "serializes correctly" do
      envelope = described_class.new(
        command: "ping",
        payload: "\x00\x00\x00\x00\x00\x00\x00\x01",
        network: "testnet"
      )

      expect(envelope.serialize).to(
        eq(
          "\v\x11\t\aping\x00\x00\x00\x00\x00\x00\x00\x00\b\x00\x00\x00:\xE5\xC1\x98\x00\x00\x00\x00\x00\x00\x00\x01"
        )
      )
    end

    it "serializes same envelope" do
      expect(parse(raw_envelope).serialize).to(eq(raw_envelope))
    end
  end
end

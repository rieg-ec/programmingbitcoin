# encoding: ascii-8bit

require "bitcoin/simple_node"
require "bitcoin/network_envelope"
require "bitcoin/verack_message"
require "helpers/encoding"

RSpec.describe Bitcoin::SimpleNode do
  include Helpers::Encoding

  describe "#wait_for" do
    let(:socket) { instance_double(Socket) }

    let(:envelope_verack) { instance_double(Bitcoin::NetworkEnvelope) }
    let(:envelope_another_msg) { instance_double(Bitcoin::NetworkEnvelope) }

    let(:verack_instance) { instance_double(Bitcoin::VerackMessage) }

    before do
      allow(Socket).to receive(:new).and_return(socket)
      allow(Socket).to receive(:pack_sockaddr_in)
      allow(socket).to receive(:connect)
      allow(socket).to receive(:local_address).and_return(double(ip_port: 8333))

      allow(envelope_verack).to receive(:command).and_return("verack")
      allow(envelope_another_msg).to receive(:command).and_return("another_msg")

      allow(Bitcoin::NetworkEnvelope).to receive(:parse).and_return(
        envelope_another_msg,
        envelope_verack
      )

      allow(envelope_verack).to receive(:stream).and_return("stream")

      allow(Bitcoin::VerackMessage).to receive(:parse).and_return(verack_instance)
    end

    it "loops while the searched message is read" do
      instance = described_class.new(host: "host", port: 1111)
      instance.wait_for(Bitcoin::VerackMessage)

      expect(Bitcoin::NetworkEnvelope).to have_received(:parse).exactly(2).times
    end

    it "returns the parsed message class" do
      instance = described_class.new(host: "host", port: 1111)
      result = instance.wait_for(Bitcoin::VerackMessage)

      expect(result).to eq(verack_instance)
    end
  end
end

require "bitcoin/script"
require "helpers/io"

RSpec.describe Bitcoin::Script do
  describe "#initialize" do
    it { expect { described_class.new([118, 169]) }.not_to raise_error }
  end

  describe "#+" do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  describe "#serialize" do
    context "when the script contains elements" do
      let(:elem_1_hex) { "11" * 5 }
      let(:elem_2_hex) { "11" * 17 }

      it "properly seriliazes the script" do
        script = described_class.new([
                                       [elem_1_hex].pack("H*"),
                                       [elem_2_hex].pack("H*")
                                     ])

        expected = "1805#{elem_1_hex}11#{elem_2_hex}"
        expect(script.serialize.unpack1("H*")).to eq(expected)
      end
    end

    context "when the script contains elements longer than 75 bytes" do
      let(:data_hex) { "11" * 80 }

      it "properly serializes the script" do
        script = described_class.new([[data_hex].pack("H*")])

        expected = "524c50#{data_hex}"
        expect(script.serialize.unpack1("H*")).to eq(expected)
      end
    end

    context "when the script contains elements longer than 255 bytes" do
      let(:data_hex) { "11" * 300 }

      it "properly serializes the script" do
        script = described_class.new([[data_hex].pack("H*")])

        expected = "fd2f014d2c01#{data_hex}"
        expect(script.serialize.unpack1("H*")).to eq(expected)
      end
    end

    context "when the script contains any other opcode" do
      let(:commands) { [78, 79, 80] }

      it "properly serializes the script" do
        script = described_class.new(commands)

        expected = "034e4f50"
        expect(script.serialize.unpack1("H*")).to eq(expected)
      end
    end
  end

  describe "#parse" do
    let(:script) { described_class.parse(raw_script) }

    def _raw_script(hex_script)
      Helpers::IO.new([hex_script].pack("H*"))
    end

    context "when the script contains elements" do
      let(:elem_1_hex) { "11" * 5 }
      let(:elem_2_hex) { "11" * 17 }
      let(:raw_script) { _raw_script("1805#{elem_1_hex}11#{elem_2_hex}") }

      it "properly parses the script" do
        expect(script.opcodes).to eq([
                                       [elem_1_hex].pack("H*"),
                                       [elem_2_hex].pack("H*")
                                     ])
      end
    end

    context "when the script contains an `OP_PUSHDATA1` opcode" do
      let(:data_hex) { "11" * 50 }
      let(:raw_script) { _raw_script("344c32#{data_hex}") }

      it "properly parses the script" do
        expect(script.opcodes).to eq([[data_hex].pack("H*")])
      end
    end

    context "when the script contains an `OP_PUSHDATA2` opcode" do
      let(:data_hex) { "11" * 300 }
      let(:raw_script) { _raw_script("fd2f014d2c01#{data_hex}") }

      it "properly parses the script" do
        expect(script.opcodes).to eq([[data_hex].pack("H*")])
      end
    end

    context "when the script contains any other opcode" do
      let(:raw_script) { _raw_script("034e4f50") }

      it "properly parses the script" do
        expect(script.opcodes).to eq([78, 79, 80])
      end
    end

    context "when the the bytes counter does not match the script length" do
      let(:raw_script) { _raw_script("0506111111111111") }

      it "raises an error" do
        expect { described_class.parse(raw_script) }.to raise_error
      end
    end
  end

  describe "#evaluate" do
    it "returns true on valid op_checksig" do
      z = 0x7c076ff316692a3d7eb3c3bb0f8b1488cf72e1afcd929e29307032997a838a3d
      sec = "\x04887387e452b8eacc4acfde10d9aaf7f6d9a0f975aabb10d006e4da568744d06c61de6d95231cd89026e2\
        86df3b6ae4a894a3378e393e93a0f45b666329a0ae34"

      sig = "\x3045022000eff69ef2b1bd93a66ed5219add4fb51e11a840f404876325a1e8ffe0529a2c02210\
        0c7207fee197d27c618aea621406f6bf5ef6fca38681d82b2f06fddbdce6feab601"

      script_pubkey = described_class.new([sec, "\0xac"])
      script_sig = described_class.new([sig])
      combined_script = script_sig + script_pubkey
      expect(combined_script.evaluate(z)).to eq(true)
    end
  end
end

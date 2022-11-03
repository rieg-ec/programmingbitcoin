require "bitcoin/script"

RSpec.describe Bitcoin::Script do
  describe "#initialize" do
    it do
      expect { described_class.new([118, 169]) }.not_to raise_error
    end
  end

  describe "#+" do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  describe "#parse" do
    pending "add some examples to (or delete) #{__FILE__}"
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

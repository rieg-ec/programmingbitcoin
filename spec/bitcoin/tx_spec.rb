require "bitcoin/tx"
require "ecc/private_key"
require "ecc/s256_point"

require "json"

RSpec.describe Bitcoin::Tx do
  let!(:txs) { JSON.parse(File.read("spec/fixtures/txs.json")) }

  before do
    allow(Bitcoin::Fetcher).to receive(:fetch_tx) do |tx_id|
      StringIO.new(Helpers::Encoding.from_hex_to_bytes(txs[tx_id]))
    end
  end

  describe "#initialize" do
    it do
      expect do
        described_class.new(
          version: 1,
          tx_ins: [],
          tx_outs: [],
          locktime: 123_123
        )
      end.not_to raise_error
    end
  end

  describe "#parse" do
    let(:raw_tx) { Bitcoin::Fetcher.fetch_tx "452c629d67e41baec3ac6f04fe744b4b9617f8f859c63b3002f8684e7a4fee03" }
    let(:tx) { described_class.parse raw_tx }

    it "properly parses the version" do
      expect(tx.version).to eq(1)
    end

    it "properly parses input count" do
      expect(tx.tx_ins.count).to eq(1)
    end

    it "properly parses each input prev_tx" do
      expect(Helpers::Encoding.from_bytes_to_hex(tx.tx_ins.first.prev_tx_id)).to eq(
        "d1c789a9c60383bf715f3f6ad9d14b91fe55f3deb369fe5d9280cb1a01793f81"
      )
    end

    it "properly parses each input prev_index" do
      expect(tx.tx_ins.first.prev_tx_index).to eq 0
    end

    it "properly parses each input script_sig" do
      expect(Helpers::Encoding.from_bytes_to_hex(tx.tx_ins.first.script_sig.serialize)).to eq "6b483045022100ed81ff192e75a3fd2304004dcadb746fa5e24c5031ccfcf21320b0277457c98f02207a986d955c6e0cb35d446a89d3f56100f4d7f67801c31967743a9c8e10615bed01210349fc4e631e3624a545de3f89f5d8684c7b8138bd94bdd531d2e213bf016b278a"
    end

    it "properly parses each input sequence" do
      expect(tx.tx_ins.first.sequence).to eq 0xfffffffe
    end

    it "properly parses output count" do
      expect(tx.tx_outs.count).to eq(2)
    end

    it "properly parses each output amount" do
      expect(tx.tx_outs.map(&:amount)).to eq([32_454_049, 10_011_545])
    end

    it "properly parses each output script_pubkey" do
      expect(tx.tx_outs.map { |o| Helpers::Encoding.from_bytes_to_hex(o.script_pubkey.serialize) }).to eq(
        %w[
          1976a914bc3b654dca7e56b04dca18f2566cdaf02e8d9ada88ac
          1976a9141c4bc762dd5423e332166702cb75f40df79fea1288ac
        ]
      )
    end

    it do
      tx = Helpers::Encoding.from_hex_to_bytes(
        "01000000022f2afe57bde0822c793604baae834f2cd26155bf1c0d37480212c107e75cd011010000006a47304402204cc5fe11b2b025f8fc9f6073b5e3942883bbba266b71751068badeb8f11f0364022070178363f5dea4149581a4b9b9dbad91ec1fd990e3fa14f9de3ccb421fa5b269012103935581e52c354cd2f484fe8ed83af7a3097005b2f9c60bff71d35bd795f54b67ffffffff153db0202de27e7944c7fd651ec1d0fab1f1aaed4b0da60d9a1b06bd771ff651010000006b483045022100b7a938d4679aa7271f0d32d83b61a85eb0180cf1261d44feaad23dfd9799dafb02205ff2f366ddd9555f7146861a8298b7636be8b292090a224c5dc84268480d8be1012103935581e52c354cd2f484fe8ed83af7a3097005b2f9c60bff71d35bd795f54b67ffffffff01d0754100000000001976a914ad346f8eb57dee9a37981716e498120ae80e44f788ac00000000"
      )
      tx_obj = described_class.parse(StringIO.new(tx), testnet: true)

      expect(tx_obj.version).to eq(1)
      expect(tx_obj.locktime).to eq(0)

      tx_ins = tx_obj.tx_ins
      expect(tx_ins[0].prev_tx_id).to eq(
        Helpers::Encoding.from_hex_to_bytes("
           11d05ce707c1120248370d1cbf5561d22c4f83aeba0436792c82e0bd57fe2a2f")
      )
      expect(tx_ins[0].prev_tx_index).to eq(1)
      expect(tx_ins[1].prev_tx_id).to eq(
        Helpers::Encoding.from_hex_to_bytes(
          "51f61f77bd061b9a0da60d4bedaaf1b1fad0c11e65fdc744797ee22d20b03d15"
        )
      )
      expect(tx_ins[1].prev_tx_index).to eq(1)

      tx_outs = tx_obj.tx_outs
      expect(tx_outs[0].amount).to eq(0.0429 * 100_000_000)
    end
  end

  describe "#serialize" do
  end

  describe "#sig_hash" do
    let(:raw_tx) do
      "0100000001813f79011acb80925dfe69b3def355fe914bd1d96a3f5f71bf8303c6a989c7d1000000006b483045\
022100ed81ff192e75a3fd2304004dcadb746fa5e24c5031ccfcf21320b0277457c98f02207a986d955c6e0cb35d446a89d\
3f56100f4d7f67801c31967743a9c8e10615bed01210349fc4e631e3624a545de3f89f5d8684c7b8138bd94bdd531d2e213\
bf016b278afeffffff02a135ef01000000001976a914bc3b654dca7e56b04dca18f2566cdaf02e8d9ada88ac99c39800000\
000001976a9141c4bc762dd5423e332166702cb75f40df79fea1288ac19430600"
    end
    let(:tx_obj) { described_class.parse StringIO.new(Helpers::Encoding.from_hex_to_bytes(raw_tx)) }

    it "returns the correct sig_hash" do
      expect(tx_obj.sig_hash(0))
        .to eq Helpers::Encoding.from_hex_to_bytes("27E0C5994DEC7824E56DEC6B2FCB342EB7CDB0D0957C2FCE9882F715E85D81A6")
    end
  end

  describe "#verify_input" do
    let(:raw_tx) do
      "0100000001813f79011acb80925dfe69b3def355fe914bd1d96a3f5f71bf8303c6a989c7d1000000006b483045\
022100ed81ff192e75a3fd2304004dcadb746fa5e24c5031ccfcf21320b0277457c98f02207a986d955c6e0cb35d446a89d\
3f56100f4d7f67801c31967743a9c8e10615bed01210349fc4e631e3624a545de3f89f5d8684c7b8138bd94bdd531d2e213\
bf016b278afeffffff02a135ef01000000001976a914bc3b654dca7e56b04dca18f2566cdaf02e8d9ada88ac99c39800000\
000001976a9141c4bc762dd5423e332166702cb75f40df79fea1288ac19430600"
    end
    let(:tx_obj) { described_class.parse StringIO.new(Helpers::Encoding.from_hex_to_bytes(raw_tx)) }

    it "verifies unlocking script unlocks the script" do
      expect(tx_obj.verify_input(0)).to be true
    end
  end

  describe "#sign_input" do
    let(:raw_tx) do
      "010000000199a24308080ab26e6fb65c4eccfadf76749bb5bfa8cb08f291320b3c21e56f0d0d00000000ffffff\
ff02408af701000000001976a914d52ad7ca9b3d096a38e752c2018e6fbc40cdf26f88ac80969800000000001976a914507\
b27411ccf7f16f10297de6cef3f291623eddf88ac00000000"
    end
    let(:tx_obj) do
      described_class.parse(
        StringIO.new(Helpers::Encoding.from_hex_to_bytes(raw_tx)),
        testnet: true
      )
    end

    let(:private_ey) { ECC::PrivateKey.new(8_675_309) }

    it "signs the input" do
      expect(tx_obj.sign_input(0, private_ey)).to be true
    end
  end
end

require "helpers/encoding"
require "ecc/s256_point"
require "ecc/private_key"
require "ecc/secp256k1_constants"

RSpec.describe ECC::S256Point do
  let(:element) { described_class.new(7, 11) }

  describe "#verify" do
    it do
      e = Helpers::Encoding.from_bytes(Helpers::Hash.hash256("my secret"))
      z = Helpers::Encoding.from_bytes(Helpers::Hash.hash256("my message"))
      k = 1_234_567_890
      r = (k * ECC::S256Point::G).x.num
      k_inv = k.pow(Secp256k1Constants::N - 2, Secp256k1Constants::N)
      s = (z + r * e) * k_inv % Secp256k1Constants::N
      point = e * ECC::S256Point::G
      expect(Helpers::Encoding.to_bytes(point.x.num, 32).unpack1("H*")).to eq(
        "028d003eab2e428d11983f3e97c3fa0addf3b42740df0d211795ffb3be2f6c52"
      )
      expect(Helpers::Encoding.to_bytes(z, 32).unpack1("H*")).to eq(
        "0231c6f3d980a6b0fb7152f85cee7eb52bf92433d9919b9c5218cb08e79cce78"
      )
      expect(Helpers::Encoding.to_bytes(r, 32).unpack1("H*")).to eq(
        "2b698a0f0a4041b77e63488ad48c23e8e8838dd1fb7520408b121697b782ef22"
      )
      expect(Helpers::Encoding.to_bytes(s, 32).unpack1("H*")).to eq(
        "bb14e602ef9e3f872e25fad328466b34e6734b7a0fcd58b1eb635447ffae8cb9"
      )
    end
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

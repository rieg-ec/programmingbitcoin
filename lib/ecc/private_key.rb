require_relative "secp256k1_constants"
require_relative "Signature"
require_relative "../helpers/encoding"
require_relative "../helpers/hash"
require "openssl"

module ECC
  class PrivateKey
    include Helpers::Encoding

    attr_reader :secret, :point

    def initialize(secret)
      @secret = secret
      @point = secret * S256Point::G
    end

    def hex
      @secret.rjust(64, "0")
    end

    def sign(m_hash)
      k = deterministic_k(m_hash)
      r = (k * S256Point::G).x.num
      k_inv = k.pow(Secp256k1Constants::N - 2, Secp256k1Constants::N)
      s = (m_hash + r * @secret) * k_inv % Secp256k1Constants::N

      s = Secp256k1Constants::N - s if s > Secp256k1Constants::N / 2

      Signature.new(r, s)
    end

    def deterministic_k(m_hash)
      k = "\x00" * 32
      v = "\x01" * 32
      m_hash -= Secp256k1Constants::N if m_hash > Secp256k1Constants::N
      m_hash_bytes = to_bytes(m_hash, 32)
      secret_bytes = to_bytes(@secret, 32)
      k = hmac_sha256(k, "#{v}\x00#{secret_bytes}#{m_hash_bytes}")
      v = hmac_sha256(k, v)
      k = hmac_sha256(k, "#{v}\x01#{secret_bytes}#{m_hash_bytes}")
      v = hmac_sha256(k, v)
      loop do
        v = hmac_sha256(k, v)
        candidate = from_bytes(v)
        return candidate if candidate > 1 && candidate < Secp256k1Constants::N

        k = hmac_sha256(k, "#{v}\x00")
        v = hmac_sha256(k, v)
      end
    end

    def to_wif(compressed: true, testnet: false)
      prefix = to_bytes(testnet ? 0xef : 0x80, 1)
      secret_bin = to_bytes(@secret, 32)
      suffix = compressed ? to_bytes(0x01, 1) : ""
      base58_encode_checksum("#{prefix}#{secret_bin}#{suffix}")
    end

    private

    def hmac_sha256(key, data)
      OpenSSL::HMAC.digest("SHA256", key, data)
    end
  end
end

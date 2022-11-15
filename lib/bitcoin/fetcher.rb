require "uri"
require "net/http"
require "stringio"

require_relative "../helpers/encoding"

module Bitcoin
  class Fetcher
    include Helpers::Encoding

    @@cache = {}

    def self.fetch(tx_id, testnet: false, fresh: false)
      return @@cache[tx_id] unless fresh || @@cache[tx_id].nil?

      uri = URI.parse("#{base_url(testnet: testnet)}/tx/#{tx_id}/hex")
      response = Net::HTTP.get(uri)
      raw = Helpers::Encoding.from_hex_to_bytes(response)

      tx = Tx.parse(StringIO.new(raw), testnet: testnet)
      raise StandardError, "not same id: #{tx.id} != #{tx_id}" if tx.id != tx_id

      @@cache[tx_id] = tx
      @@cache[tx_id].testnet = testnet
      tx
    end

    def self.base_url(testnet: false)
      testnet ? "https://blockstream.info/testnet/api" : "https://blockstream.info/api"
    end

    private_class_method :base_url
  end
end

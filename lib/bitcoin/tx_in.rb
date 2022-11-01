require_relative "../helpers/io"
require_relative "../helpers/encoding"
require_relative "script"
require_relative "fetcher"

module Bitcoin
  class TxIn
    def initialize(prev_tx_id, prev_index, script_sig = nil, sequence = 0xffffffff)
      @prev_tx_id = prev_tx_id
      @prev_index = prev_index
      @script_sig = script_sig || Script.new
      @sequence = sequence
    end

    def fetch_tx(testnet: false)
      Fetcher.fetch(to_bytes(@prev_tx_id, 4), testnet: testnet)
    end

    # returns output value by looking up tx hash
    def value(testnet: false)
      tx = fetch_tx(testnet: testnet)
      tx.tx_outs[@prev_index].amount
    end

    def script_pubkey(testnet: false)
      tx = fetch_tx(testnet: testnet)
      tx.tx_outs[@prev_index].script_pubkey
    end

    def self.parse(io)
      prev_tx_id = io.read_le(32)
      prev_tx_index = io.read_le_int32
      script_sig = Script.parse(io)
      sequence = io.read_le_int32
      new(prev_tx_id, prev_index, script_sig, sequence)
    end

    def serialize
      prev_tx_id = to_bytes(@prev_tx_id, 32, "little")
      prev_tx_index = to_bytes(@prev_tx_index, 4, "little")
      script_sig = @script_sig.serialize
      sequence = to_bytes(@sequence, 4, "little")

      "#{prev_tx_id}#{prev_tx_index}#{script_sig}#{sequence}"
    end
  end
end

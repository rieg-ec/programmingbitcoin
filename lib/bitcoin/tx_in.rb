require_relative "../helpers/io"
require_relative "../helpers/encoding"
require_relative "script"
require_relative "fetcher"

module Bitcoin
  class TxIn
    attr_accessor :script_sig
    attr_reader :prev_tx_id, :prev_tx_index, :sequence

    def initialize(prev_tx_id:, prev_tx_index:, script_sig: nil, sequence: 0xffffffff)
      @prev_tx_id = prev_tx_id
      @prev_tx_index = prev_tx_index
      @script_sig = script_sig || Script.new
      @sequence = sequence
    end

    def to_s
      "#{@prev_tx_id.unpack1("H*")}:#{@prev_tx_index}"
    end

    def coinbase?
      @prev_tx_id == "\x00" * 32 && @prev_tx_index == 0xffffffff
    end

    def fetch_tx(testnet: false)
      Fetcher.fetch(
        Helpers::Encoding.from_bytes_to_hex(@prev_tx_id),
        testnet: testnet
      )
    end

    # returns output value by looking up tx hash
    def value(testnet: false)
      tx = fetch_tx(testnet: testnet)
      tx.tx_outs[@prev_tx_index].amount
    end

    def script_pubkey(testnet: false)
      tx = fetch_tx(testnet: testnet)
      tx.tx_outs[@prev_tx_index].script_pubkey
    end

    def self.parse(io)
      prev_tx_id = io.read_le(32)
      prev_tx_index = io.read_le_int32
      script_sig = Script.parse(io)
      sequence = io.read_le_int32

      new(
        prev_tx_id: prev_tx_id,
        prev_tx_index: prev_tx_index,
        script_sig: script_sig,
        sequence: sequence
      )
    end

    def serialize
      result = @prev_tx_id.reverse
      result << Helpers::Encoding.to_bytes(@prev_tx_index, 4, "little")
      result << @script_sig.serialize
      result << Helpers::Encoding.to_bytes(@sequence, 4, "little")

      result
    end
  end
end

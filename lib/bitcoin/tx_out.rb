require_relative "../helpers/io"
require_relative "../helpers/encoding"
require_relative "script"

module Bitcoin
  class TxOut
    attr_reader :amount, :script_pubkey

    def initialize(amount:, script_pubkey:)
      @amount = amount
      @script_pubkey = script_pubkey
    end

    def to_s
      "#{@amount}: #{@script_pubkey}"
    end

    def self.parse(io)
      amount = io.read_le_int64
      script_pubkey = Script.parse(io)
      new(amount: amount, script_pubkey: script_pubkey)
    end

    def serialize
      "#{Helpers::Encoding.to_bytes(@amount, 8, "little")}#{@script_pubkey.serialize}"
    end
  end
end

require_relative "../helpers/io"
require_relative "../helpers/encoding"
require_relative "script"

module Bitcoin
  class TxOut
    def initialize(amount, script_pubkey)
      @amount = amount
      @script_pubkey = script_pubkey
    end

    def self.parse(io)
      value = io.read_le_int64
      script_pubkey = Script.parse(io)
      new(value, script_pubkey)
    end

    def serialize
      "#{to_bytes(@amount, 8, "little")}#{script_pubkey.serialize}"
    end
  end
end

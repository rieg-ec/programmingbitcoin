# encoding: ascii-8bit

require_relative "./block"
require_relative "./base_message"
require_relative "../helpers/encoding"

module Bitcoin
  class HeadersMessage < BaseMessage
    COMMAND = "headers".freeze

    attr_reader :headers

    def initialize(headers)
      @headers = headers
    end

    def self.parse(io)
      version = io.read_le_int32
      num_hashes = Helpers::Encoding.read_varint(io)

      blocks = []
      num_hashes.times do
        blocks << Block.parse(io)
        txs_count = Helpers::Encoding.read_varint(io)
      end

      new(blocks)
    end
  end
end

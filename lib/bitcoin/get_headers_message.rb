# encoding: ascii-8bit

require_relative "../helpers/encoding"
require_relative "./base_message"

module Bitcoin
  class GetHeadersMessage < BaseMessage
    include Helpers::Encoding
    COMMAND = "getheaders".freeze

    def initialize(version: 70_015, num_hashes: 1, start_block: nil, end_block: nil)
      @version = version
      @num_hashes = num_hashes

      raise ArgumentError, "start_block is required" if start_block.nil?

      @start_block = start_block
      @end_block = end_block || "\x00" * 32
    end

    def serialize
      command = to_bytes(@version, 4, "little")
      command << encode_varint(@num_hashes)
      command << @start_block
      command << @end_block
    end
  end
end

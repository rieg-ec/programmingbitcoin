# encoding: ascii-8bit

require_relative "../helpers/encoding"
require_relative "./base_message"

module Bitcoin
  class GetDataMessage < BaseMessage
    include Helpers::Encoding
    COMMAND = "getdata".freeze

    def initialize(num_data:, type:, hash:)
      @num_data = num_data
      @type = type
      @hash = hash
    end

    def serialize
      command = encode_varint(@num_data)
      command << to_bytes(@type, 4, "little")
      command << @hash
    end
  end
end

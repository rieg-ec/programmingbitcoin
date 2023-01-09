require_relative "./base_message"
require_relative "../helpers/encoding"

module Bitcoin
  class FilterloadMessage < BaseMessage
    include Helpers::Encoding

    COMMAND = "filterload".freeze

    def initialize(bloom_filter)
      @bloom_filter = bloom_filter
    end

    def serialize
      bytes = encode_varint(@bloom_filter.size)
      bytes << bit_field_to_bytes(@bloom_filter.bit_field)
      bytes << to_bytes(@bloom_filter.function_count, 4, "little")
      bytes << to_bytes(@bloom_filter.tweak, 4, "little")
      bytes << "\x00"

      bytes
    end
  end
end

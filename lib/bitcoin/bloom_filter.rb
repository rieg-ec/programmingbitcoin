require_relative "../helpers/murmur3"
require_relative "../helpers/encoding"
require_relative "./filterload_message"

module Bitcoin
  class BloomFilter
    include Helpers::Murmur3

    BIP37_CONSTANT = 0xfba4c795

    def initialize(size, function_count, tweak)
      @size = size
      @function_count = function_count
      @tweak = tweak
      @bit_field = Array.new(size * 8, 0)
    end

    attr_reader :bit_field, :size, :function_count, :tweak

    def add(item)
      @function_count.times do |i|
        seed = i * BIP37_CONSTANT + @tweak
        @bit_field[bit_index(item, seed)] = 1
      end
    end

    def filterload
      Bitcoin::FilterloadMessage.new(self)
    end

    private

    def bit_index(item, seed)
      murmur_32(item, seed: seed) % (@size * 8)
    end
  end
end

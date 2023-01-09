require "digest"

module Helpers
  module Murmur3
    MASK32 = 0xFFFFFFFF
    # rubocop:disable Metrics/MethodLength
    def murmur_32(string, seed: 0) # rubocop:disable Metrics/AbcSize
      key_bytes = string.bytes
      result_hash = seed

      rounded_end = (key_bytes.length & 0xfffffffc)
      (0...rounded_end).step(4) do |i|
        aux = block32(key_bytes, i)
        result_hash ^= scramble32(aux)
        result_hash = rotl32(result_hash, 13)
        result_hash = result_hash * 5 + 0xe6546b64
      end

      val = key_bytes.length & 3

      aux = 0
      (0...3).reverse_each do |i|
        aux |= (key_bytes[rounded_end + i] & 0xff) << (8 * i) if val >= (i + 1)
      end

      result_hash ^= scramble32(aux)
      finalization_mix(result_hash ^ key_bytes.length)
    end
    # rubocop:enable Metrics/MethodLength

    private

    def finalization_mix(result_hash)
      result_hash ^= ((result_hash & MASK32) >> 16)
      result_hash *= 0x85ebca6b
      result_hash ^= ((result_hash & MASK32) >> 13)
      result_hash *= 0xc2b2ae35
      (result_hash ^ ((result_hash & MASK32) >> 16)) & MASK32
    end

    def block32(key_bytes, index)
      (1..3).map do |i|
        key_bytes[index + i] << (8 * i)
      end.reduce(key_bytes[index], :|)
    end

    def rotl32(item, bits_to_rotate)
      ((item << bits_to_rotate) | ((item & MASK32) >> (32 - bits_to_rotate))) & MASK32
    end

    def scramble32(aux)
      aux = (aux * 0xcc9e2d51) & MASK32
      aux = rotl32(aux, 15)
      (aux * 0x1b873593) & MASK32
    end
  end
end

require_relative "../helpers/hash"
require_relative "../helpers/encoding"

module Bitcoin
  class MerkleTree
    attr_reader :nodes, :current_depth, :current_index

    def initialize(leaf_count)
      @height = Math.log2(leaf_count).ceil
      @nodes = build_tree(leaf_count)
      @current_depth = 0
      @current_index = 0
    end

    def self.merkle_root(nodes)
      return nodes.first if nodes.size == 1

      current_nodes = nodes
      while current_nodes.size > 1
        current_nodes = current_nodes.each_slice(2).map do |left, right|
          right = left.dup if right.nil?
          merkle_parent(left, right)
        end
      end

      current_nodes.first
    end

    def self.parse_merkle_block(io)
      block = Bitcoin::Block.parse(io)
      tx_count = io.read_le_int32
      tx_hashes = io.read_varint.times.map { io.read(32) }
      flag_bytes = io.read_varint
    end

    def self.merkle_parent_level(nodes)
      parent_level = []
      nodes.append nodes.last if nodes.size.odd?

      nodes.each_slice(2) do |left, right|
        parent_level << merkle_parent(left, right)
      end

      parent_level
    end

    def self.merkle_parent(left, right)
      Helpers::Hash.hash256(left + right)
    end

    def self.bytes_to_bit_field(bytes)
      flag_bits = []
      bytes.each_byte do |byte|
        8.times do
          flag_bits << (byte & 1)
          byte >>= 1
        end
      end
      flag_bits
    end

    def populate_tree(flag_bits, hashes)
      until root
        next handle_leaf(flag_bits, hashes) if leaf?

        left_hash = left_node
        next handle_left(flag_bits, hashes) if left_hash.nil?
        next handle_right(flag_bits, hashes) if right_node_exists?

        set_current_node(self.class.merkle_parent(left_hash, left_hash))
        up
      end
    end

    def valid?
      # @TODO
    end

    def root
      @nodes[0][0]
    end

    private

    def handle_leaf(flag_bits, hashes)
      flag_bits.shift
      set_current_node(hashes.shift)
      up
    end

    def handle_left(flag_bits, hashes)
      if flag_bits.shift == 0
        set_current_node(hashes.shift)
        up
      else
        left
      end
    end

    def handle_right(_flag_bits, _hashes)
      right_hash = right_node
      return right if right_hash.nil?

      set_current_node(self.class.merkle_parent(left_node, right_hash))
      up
    end

    def up
      @current_depth -= 1
      @current_index /= 2
    end

    def left
      @current_depth += 1
      @current_index *= 2
    end

    def right
      @current_depth += 1
      @current_index = @current_index * 2 + 1
    end

    def set_current_node(value)
      @nodes[@current_depth][@current_index] = value
    end

    def current_node
      @nodes[@current_depth][@current_index]
    end

    def left_node
      @nodes[@current_depth + 1][@current_index * 2]
    end

    def right_node
      @nodes[@current_depth + 1][@current_index * 2 + 1]
    end

    def leaf?
      @current_depth == @height
    end

    def right_node_exists?
      @nodes[@current_depth + 1].size > @current_index * 2 + 1
    end

    def build_tree(leaf_count)
      tree = []
      (0..@height + 1).each do |level|
        nodes_in_level = (leaf_count.to_f / 2**(@height - level)).ceil
        blank_hashes = Array.new(nodes_in_level)
        tree << blank_hashes
      end
      tree
    end
  end
end

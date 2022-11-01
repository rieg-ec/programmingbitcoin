require_relative "../helpers/hash"
require_relative "../helpers/io"
require_relative "../helpers/encoding"
require_relative "fetcher"

module Bitcoin
  class Tx
    include Helpers::Encoding

    def initialize(version, tx_ins, tx_outs, locktime, testnet: false)
      @version = version
      @tx_ins = tx_ins
      @tx_outs = tx_outs
      @version = version
      @locktime = locktime
      @testnet = testnet
    end

    def id
      hash.unpack1("H*") # @TODO not sure if little or big endian
    end

    def to_s
      tx_ins = @tx_ins.map(&:to_s).join
      tx_outs = @tx_outs.map(&:to_s).join

      "version: #{@version}\n" +
        "tx_ins: #{tx_ins}\n" +
        "tx_outs: #{tx_outs}\n" +
        "locktime: #{@locktime}\n" +
        "testnet: #{@testnet}\n"
    end

    def self.parse(stream, testnet: false)
      # @TODO what kind of streams are we expecting?
      # this fails if stream is a plain String object
      io = Helpers::IO.new(stream)

      version = io.read_le_int32
      tx_ins = io.read_var_int.times.map { TxIn.parse(io) }
      tx_outs = io.read_var_int.times.map { TxOut.parse(io) }
      locktime = io.read_le_int32

      new(version, tx_ins, tx_outs, locktime, testnet)
    end

    def fee
      tx_out_sum = @tx_outs.map(&:amount).sum
      tx_in_sum = @tx_ins.map { |tx_in| tx_in.value(testnet: @testnet) }.sum
      tx_in_sum - tx_out_sum
    end

    def serialize
      tx_ins = @tx_ins.map(&:serialize).join
      tx_outs = @tx_outs.map(&:serialize).join

      "#{to_bytes(@version, 4, "little")}" +
        "#{encode_varint(tx_ins.length)}#{tx_ins}" +
        "#{encode_varint(tx_outs.length)}#{tx_outs}" +
        "#{to_bytes(@locktime, 4, "little")}"
    end

    private

    def hash
      Helpers::Hash.hash256(serialize)
    end

    def serialize
      raise NotImplementedError
    end
  end
end

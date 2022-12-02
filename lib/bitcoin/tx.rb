require_relative "../helpers/hash"
require_relative "../helpers/io"
require_relative "../helpers/encoding"
require_relative "./tx_in"
require_relative "./tx_out"

module Bitcoin
  class Tx
    include Helpers::Encoding

    SIGHASH_ALL = 1

    attr_accessor :testnet
    attr_reader :version, :tx_ins, :tx_outs, :locktime

    def initialize(version:, tx_ins:, tx_outs:, locktime:, testnet: false)
      @version = version
      @tx_ins = tx_ins
      @tx_outs = tx_outs
      @version = version
      @locktime = locktime
      @testnet = testnet
    end

    def id
      hash.reverse.unpack1("H*")
    end

    def to_s
      tx_ins = @tx_ins.map(&:to_s).join("\n")
      tx_outs = @tx_outs.map(&:to_s).join("\n")

      "tx: #{id}\n" +
        "version: #{@version}\n" +
        "tx_ins:\n#{tx_ins}\n" +
        "tx_outs:\n#{tx_outs}\n" +
        "locktime: #{@locktime}\n" +
        "testnet: #{@testnet}\n"
    end

    def self.parse(stream, testnet: false)
      io = Helpers::IO.new(stream)

      version = io.read_le_int32
      tx_ins = io.read_varint.times.map { TxIn.parse(io) }
      tx_outs = io.read_varint.times.map { TxOut.parse(io) }
      locktime = io.read_le_int32

      new(
        version: version,
        tx_ins: tx_ins,
        tx_outs: tx_outs,
        locktime: locktime,
        testnet: testnet
      )
    end

    def fee
      tx_out_sum = @tx_outs.map(&:amount).sum
      tx_in_sum = @tx_ins.map { |tx_in| tx_in.value(testnet: @testnet) }.sum
      tx_in_sum - tx_out_sum
    end

    def serialize
      tx_ins = @tx_ins.map(&:serialize).join
      tx_outs = @tx_outs.map(&:serialize).join

      "#{Helpers::Encoding.to_bytes(@version, 4, "little")}" +
        "#{Helpers::Encoding.encode_varint(@tx_ins.length)}#{tx_ins}" +
        "#{Helpers::Encoding.encode_varint(@tx_outs.length)}#{tx_outs}" +
        "#{Helpers::Encoding.to_bytes(@locktime, 4, "little")}"
    end

    def verify
      return false if fee.negative?

      @tx_ins.each_with_index do |_tx_in, index|
        return false unless verify_input(index)
      end

      true
    end

    # returns the signature hash by removing the scriptSig and replacing it with
    # the scriptPubKey of the corresponding input. This is the hash that is
    # signed by the private key.
    def sig_hash(index, redeem_script: nil)
      sig = Helpers::Encoding.to_bytes(@version, 4, "little")
      sig << Helpers::Encoding.encode_varint(@tx_ins.length)

      sig << @tx_ins.map.with_index do |tx_in, i|
        if i == index
          tx_in.script_sig = if redeem_script.present?
                               redeem_script
                             else
                               tx_in.script_pubkey(testnet: @testnet)
                             end
        end
        tx_in.serialize
      end.join

      sig << Helpers::Encoding.encode_varint(@tx_outs.length)
      sig << @tx_outs.map(&:serialize).join
      sig << Helpers::Encoding.to_bytes(@locktime, 4, "little")
      sig << Helpers::Encoding.to_bytes(SIGHASH_ALL, 4, "little")

      Helpers::Hash.hash256(sig)
    end

    def verify_input(index)
      tx_in = @tx_ins[index]
      script_pubkey = tx_in.script_pubkey(testnet: @testnet)

      if script_pubkey.p2sh?
        cmd = tx_in.script_sig.opcodes.last
        raw_redeem = Helpers::Encoding.encode_varint(cmd.length) + cmd
        redeem_script = Script.parse(StringIO.new(raw_redeem))
      else
        redeem_script = nil
      end

      z = sig_hash(index, redeem_script: redeem_script)
      combined = tx_in.script_sig + script_pubkey

      combined.evaluate(z)
    end

    def sign_input(index, privkey)
      z = sig_hash(index)
      der = privkey.sign(z).der
      sig = der + Helpers::Encoding.to_bytes(SIGHASH_ALL, 1)
      sec = privkey.point.sec
      @tx_ins[index].script_sig = Script.new([sig, sec])
      verify_input(index)
    end

    private

    def hash
      Helpers::Hash.hash256(serialize)
    end
  end
end

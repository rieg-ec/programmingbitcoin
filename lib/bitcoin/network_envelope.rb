require_relative "../helpers/encoding"
require_relative "../helpers/hash"
require_relative "../helpers/io"

module Bitcoin
  class NetworkEnvelope
    include Helpers::Encoding

    TESTNET_MAGIC = "0b110907".freeze
    MAINNET_MAGIC = "f9beb4d9".freeze
    REGTEST_MAGIC = "fabfb5da".freeze

    NETWORK_TO_MAGIC = {
      "testnet" => TESTNET_MAGIC,
      "mainnet" => MAINNET_MAGIC,
      "regtest" => REGTEST_MAGIC
    }

    attr_reader :command, :magic, :payload

    def initialize(command:, payload:, network: "regtest")
      @command = command
      @payload = payload
      @magic = NETWORK_TO_MAGIC[network]
    end

    def to_s
      serialize
    end

    def serialize
      envelope = from_hex_to_bytes(@magic.dup)
      envelope << @command.ljust(12, "\x00")
      envelope << to_bytes(@payload.length, 4, "little")
      envelope << self.class.computed_checksum(@payload)
      envelope << @payload
      envelope
    end

    def stream
      Helpers::IO.new(@payload)
    end

    # rubocop:disable Metrics/MethodLength
    def self.parse(io)
      magic = io.read(4)
      raise IOError, "no data received" if magic.nil?

      magic = Helpers::Encoding.from_bytes_to_hex(magic)

      raise IOError, "unrecognized network magic" unless [
        MAINNET_MAGIC, TESTNET_MAGIC, REGTEST_MAGIC
      ].include? magic

      command = io.read(12).delete("\x00")
      payload_length = io.read_le_int32
      checksum = io.read(4)
      payload = io.read(payload_length)

      raise "Invalid checksum" unless
        checksum == computed_checksum(payload)

      network = NETWORK_TO_MAGIC.key(magic)

      new(
        command: command,
        payload: payload,
        network: network
      )
    end
    # rubocop:enable Metrics/MethodLength

    def self.computed_checksum(payload)
      Helpers::Hash.hash256(payload)[0..3]
    end
  end
end

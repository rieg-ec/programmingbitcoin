require "stringio"
require "pry"

require_relative "../../lib/helpers/io"
require_relative "../../lib/bitcoin/network_envelope"
require_relative "../../lib/bitcoin/version_message"

message = "f9beb4d976657261636b000000000000000000005df6e0e2"

network_envelope = Bitcoin::NetworkEnvelope.parse(
  StringIO.new(Helpers::Encoding.from_hex_to_bytes(message))
)

# puts network_envelope

# puts network_envelope.serialize

puts Bitcoin::VersionMessage.new.serialize

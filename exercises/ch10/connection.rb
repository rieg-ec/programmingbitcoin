require "stringio"
require "socket"
require "pry"

require_relative "../../lib/helpers/io"
require_relative "../../lib/bitcoin/network_envelope"
require_relative "../../lib/bitcoin/version_message"

version = Bitcoin::VersionMessage.new
envelop = Bitcoin::NetworkEnvelope.new(
  command: version.command,
  payload: version.serialize,
  testnet: true
)

socket = TCPSocket.new("localhost", 18_444)
message = Helpers::Encoding.from_hex_to_bytes(envelop.serialize)
socket.puts message
puts socket.gets # Print sever response

socket.close

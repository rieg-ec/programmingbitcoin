require "stringio"
require "socket"
require "pry"

require_relative "../../lib/helpers/io"
require_relative "../../lib/bitcoin/network_envelope"
require_relative "../../lib/bitcoin/verack_message"
require_relative "../../lib/bitcoin/version_message"
require_relative "../../lib/bitcoin/get_headers_message"
require_relative "../../lib/bitcoin/headers_message"
require_relative "../../lib/bitcoin/simple_node"
require_relative "../../lib/bitcoin/block"

node = Bitcoin::SimpleNode.new(host: "0.0.0.0", port: 18_501, network: "regtest")
version = Bitcoin::VersionMessage.new(sender_port: node.sender_port)
node.handshake

genesis = Bitcoin::Block.parse(Helpers::IO.new(Bitcoin::Block::GENESIS_BLOCK))
getheaders = Bitcoin::GetHeadersMessage.new(start_block: genesis.hash)
node.send(getheaders)

headers_message = node.wait_for(Bitcoin::HeadersMessage)

puts headers_message.headers
puts headers_message.headers.map(&:pow_valid?)

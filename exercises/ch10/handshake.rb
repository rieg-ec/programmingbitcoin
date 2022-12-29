require "stringio"
require "socket"
require "pry"

require_relative "../../lib/helpers/io"
require_relative "../../lib/bitcoin/network_envelope"
require_relative "../../lib/bitcoin/verack_message"
require_relative "../../lib/bitcoin/version_message"
require_relative "../../lib/bitcoin/simple_node"

node = Bitcoin::SimpleNode.new(host: "0.0.0.0", port: 18_501, network: "regtest")
version = Bitcoin::VersionMessage.new(sender_port: node.sender_port)
node.send(version)

loop do
  puts "Waiting for messages..."
  message = node.wait_for(Bitcoin::VerackMessage)
  puts "Received #{message.class}"
  case message.command
  when "verack"
    puts "verack received"
    break
  when "version"
    node.send(Bitcoin::VerackMessage.new)
    puts "sending verack"
  end
end

node.close

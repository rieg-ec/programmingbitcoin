require "socket"

require_relative "./network_envelope"

module Bitcoin
  class SimpleNode
    COMMON_PORTS = {
      "testnet" => 18_333,
      "mainnet" => 8333,
      "regtest" => 18_444
    }

    attr_reader :sender_port

    def initialize(host:, port: nil, logging: true, network: "regtest")
      @logging = logging
      @network = network

      connect(port || COMMON_PORTS[network], host)
      @sender_port = @socket.local_address.ip_port
    end

    def send(message)
      envelop = NetworkEnvelope.new(
        command: message.command,
        payload: message.serialize,
        network: @network
      )
      puts "sending #{envelop.serialize}..." if @logging
      @socket.send(envelop.serialize, 0)
    end

    def read_envelope
      begin
        envelope = NetworkEnvelope.parse(@socket)
      rescue IOError
        puts "no data received" if @logging
        return nil
      end

      puts "receiving #{envelope}" if @logging

      envelope
    end

    def wait_for(*message_classes)
      command = nil
      command_to_class = message_classes.to_h { |msg_class| [msg_class::COMMAND, msg_class] }

      until command_to_class.key?(command)
        envelope = read_envelope
        puts "received #{envelope}" if @logging && !envelope.nil?
        if envelope.nil?
          sleep(1)
          next
        end

        command = envelope.command
        puts "command received: #{command}" if @logging
        send(VerackMessage.new) if command == "version"
        send(PongMessage.new) if command == "ping"
      end

      command_to_class[command].parse(envelope.stream)
    end

    def close
      @socket.close
    end

    private

    def connect(port, host)
      @socket = Socket.new Socket::AF_INET, Socket::SOCK_STREAM

      puts "connecting..." if @logging
      @socket.connect(Socket.pack_sockaddr_in(port, host))
      puts "running socket on port #{@socket.local_address.ip_port}" if @logging
    end
  end
end

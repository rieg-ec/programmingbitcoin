# encoding: ascii-8bit

require_relative "../helpers/encoding"
require_relative "./base_message"

module Bitcoin
  class VersionMessage < BaseMessage
    include Helpers::Encoding
    COMMAND = "version".freeze

    # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
    def initialize(
      version: 70_015,
      services: 0,
      timestamp: nil,
      receiver_services: 0,
      receiver_ip: "\x00\x00\x00\x00",
      receiver_port: 8333,
      sender_services: 0,
      sender_ip: "\x00\x00\x00\x00",
      sender_port: 8333,
      nonce: nil,
      user_agent: "/programmingbitcoin:0.1/",
      latest_block: 0,
      relay: false
    )

      @version = version
      @services = services

      @timestamp = if timestamp.nil?
                     Time.now.to_i
                   else
                     timestamp
                   end

      @receiver_services = receiver_services
      @receiver_ip = receiver_ip
      @receiver_port = receiver_port
      @sender_services = sender_services
      @sender_ip = sender_ip
      @sender_port = sender_port

      @nonce = nonce.nil? ? 0 : nonce

      @user_agent = user_agent
      @latest_block = latest_block
      @relay = relay
    end
    # rubocop:enable Metrics/ParameterLists, Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def serialize
      command = to_bytes(@version, 4, "little")
      command << to_bytes(@services, 8, "little")
      command << to_bytes(@timestamp, 8, "little")
      command << to_bytes(@receiver_services, 8, "little")
      command << "\x00" * 10 + "\xff\xff" + @receiver_ip
      command << to_bytes(@receiver_port, 2)
      command << to_bytes(@sender_services, 8, "little")
      command << "\x00" * 10 + "\xff\xff" + @sender_ip
      command << to_bytes(@sender_port, 2)
      command << to_bytes(@nonce, 8, "little")
      command << to_bytes(@user_agent.length, 1)
      command << @user_agent
      command << to_bytes(@latest_block, 4, "little")
      command << to_bytes(@relay ? 1 : 0, 1)
      command
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end

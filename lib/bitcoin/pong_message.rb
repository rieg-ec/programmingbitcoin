require_relative "./base_message"

module Bitcoin
  class PongMessage < BaseMessage
    COMMAND = "pong"

    def initialize(nonce)
      @nonce = nonce
    end

    def serialize
      @nonce
    end

    def self.parse(stream)
      nonce = stream.read(8)
      new(nonce)
    end
  end
end

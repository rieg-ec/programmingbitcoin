require_relative "./base_message"

module Bitcoin
  class VerackMessage < BaseMessage
    COMMAND = "verack".freeze

    def initialize; end

    def self.parse(_)
      new
    end

    def serialize
      ""
    end
  end
end

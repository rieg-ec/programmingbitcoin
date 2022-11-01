require "digest"

module Helpers
  module Hash
    def self.hash160(string)
      first_round = Digest::SHA256.digest(string)
      Digest::RMD160.digest(first_round)
    end

    def self.hash256(string)
      first_round = Digest::SHA256.digest(string)
      Digest::SHA256.digest(first_round)
    end
  end
end

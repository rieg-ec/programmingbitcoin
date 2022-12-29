module Bitcoin
  class BaseMessage
    def command
      self.class::COMMAND
    end
  end
end

module SimpleQueues
  class IdentityEncoder
    def encode(message)
      message
    end

    def decode(message)
      message
    end
  end
end

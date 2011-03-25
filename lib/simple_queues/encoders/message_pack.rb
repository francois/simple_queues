require "msgpack"

module SimpleQueues
  class MessagePackEncoder
    def encode(message)
      MessagePack.pack(message)
    end

    def decode(message)
      MessagePack.unpack(message)
    end
  end
end

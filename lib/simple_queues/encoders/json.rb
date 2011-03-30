require "json"

module SimpleQueues
  class JsonEncoder
    def encode(message)
      message.to_json
    end

    def decode(message)
      JSON.parse(message)
    end
  end
end

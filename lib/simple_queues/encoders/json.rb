require "json"

module SimpleQueues
  class JsonEncoder
    def encode(message)
      JSON.generate(message)
    end

    def decode(message)
      JSON.parse(message)
    end
  end
end

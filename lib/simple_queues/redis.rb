module SimpleQueues
  class Redis
    def initialize(redis=Redis.new)
      @redis = redis
    end

    def enqueue(queue_name, message)
      raise ArgumentError, "Queue name argument was nil - must not be" if queue_name.nil? || queue_name.to_s.empty?
      raise ArgumentError, "Message argument was nil - must not be" if message.nil?

      @redis.rpush(queue_name.to_s, message.to_s)
    end

    def dequeue_blocking(queue_name)
      dequeue_with_timeout(queue_name, 0)
    end

    def dequeue_with_timeout(queue_name, timeout)
      raise ArgumentError, "Queue name argument was nil - must not be" if queue_name.nil? || queue_name.to_s.empty?

      @redis.blpop(queue_name.to_s, timeout)
    end
  end
end

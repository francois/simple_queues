autoload :Redis, "redis"

module SimpleQueues
  # The Redis version of SimpleQueues.
  #
  # Messages are enqueued to the right, dequeued from the left - thus the most recent messages are at the end of the list.
  class Redis
    def initialize(redis = ::Redis.new)
      @redis = redis
    end

    # Enqueues a new message to the Redis backend.
    #
    # @param queue_name [String, Symbol] The queue name, which must not be nil or the empty String.
    # @param message [#to_s] The message to be enqueued. The message will be turned into a String through #to_s before being enqueued. Must not be nil, but the empty string is accepted, although it seems meaningless to do so.
    # @return No useful value.
    # @raise ArgumentError Whenever the queue name or the message are nil, or the queue name is empty.
    def enqueue(queue_name, message)
      raise ArgumentError, "Queue name argument was nil - must not be" if queue_name.nil? || queue_name.to_s.empty?
      raise ArgumentError, "Message argument was nil - must not be" if message.nil?

      @redis.rpush(queue_name.to_s, message.to_s)
    end

    # Dequeues a message, and waits forever for one to arrive.
    #
    # @param queue_name [String, Symbol] The queue name to read from.
    # @return [String] The first message in the queue.
    # @raise ArgumentError If +queue_name+ is nil or the empty String.
    def dequeue_blocking(queue_name)
      dequeue_with_timeout(queue_name, 0)
    end

    # Dequeues a message, or returns +nil+ if the timeout is exceeded.
    #
    # @param queue_name [String, Symbol] The queue name to read from.
    # @param timeout [#to_i] The number of seconds to wait before returning nil.
    # @return [String, nil] The first message in the queue, or nil if the timeout was exceeded.
    # @raise ArgumentError If +queue_name+ is nil or the empty String.
    def dequeue_with_timeout(queue_name, timeout)
      raise ArgumentError, "Queue name argument was nil - must not be" if queue_name.nil? || queue_name.to_s.empty?

      @redis.blpop(queue_name.to_s, timeout)
    end
  end
end

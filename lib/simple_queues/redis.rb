require "redis"
require 'json'

module SimpleQueues
  # The Redis version of SimpleQueues.
  #
  # Messages are enqueued to the right, dequeued from the left - thus the most recent messages are at the end of the list.
  class Redis
    def initialize(redis = ::Redis.new)
      @redis  = redis
      @queues = Hash.new
    end

    def on_dequeue(queue_name, &block)
      @queues[q_name(queue_name)] = block
    end

    def serialize(message)
      raise ArgumentError, "message must be non-nil" if message.nil?
      raise ArgumentError, "message must be respond to #to_json" unless message.respond_to?(:to_json)
      message.to_json
    end

    def deserialize(message)
      JSON.parse(message) if message
    end

    # Enqueues a new message to the Redis backend.
    #
    # @param queue_name [String, Symbol] The queue name, which must not be nil or the empty String.
    # @param message [#to_s] The message to be enqueued. The message will be turned into a String through #to_s before being enqueued. Must not be nil, but the empty string is accepted, although it seems meaningless to do so.
    # @return No useful value.
    # @raise ArgumentError Whenever the queue name or the message are nil, or the queue name is empty.
    def enqueue(queue_name, message)
      msg = serialize(message)
      @redis.rpush(q_name(queue_name), msg)
      msg
    end

    # Dequeues a message, and waits forever for one to arrive.
    #
    # @param queue_name [String, Symbol] The queue name to read from.
    # @return [String] The first message in the queue.
    # @raise ArgumentError If +queue_name+ is nil or the empty String.
    def dequeue_blocking(queue_name)
      dequeue_with_timeout(queue_name, 0)
    end

    def clear(queue_name)
      @redis.ltrim(q_name(queue_name), 1, 0)
    end

    def size(queue_name)
      @redis.llen(q_name(queue_name))
    end

    # Dequeues a message, or returns +nil+ if the timeout is exceeded.
    #
    # @param queue_name [String, Symbol] The queue name to read from. Optional if you used #on_dequeue.
    # @param timeout [#to_f] The number of seconds to wait before returning nil.
    # @return [String, nil] When given two arguments, returns the message, or nil if the timeout was exceeded. When given a timeout only, always returns nil.
    # @raise ArgumentError If +queue_name+ is absent and no #on_dequeue blocks were added.
    def dequeue_with_timeout(*args)
      case args.length
      when 1 # Timeout only
        timeout = args.shift
        raise ArgumentError, "Timeout must not be nil" if timeout.nil? || timeout.to_s.empty?

        queue, result = @redis.blpop(*@queues.keys, timeout.to_i)
        @queues.fetch(queue).call(deserialize(result)) if queue
        queue
      when 2
        queue_name, timeout = args.shift, args.shift
        _, result = @redis.blpop(q_name(queue_name), timeout.to_i)
        deserialize(result)
      else
        raise "NOT DONE"
      end

    end

  private
    def q_name(queue_name)
      queue_name &&= queue_name.to_s
      raise ArgumentError, "Queue name argument was nil - must not be" if queue_name.nil? || queue_name.empty?
      queue_name
    end
  end
end

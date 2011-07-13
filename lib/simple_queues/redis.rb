require "redis"
require 'json'

module SimpleQueues
  # The Redis version of SimpleQueues.
  #
  # Messages are enqueued to the right, dequeued from the left - thus the most recent messages are at the end of the list.
  class Redis
    attr_accessor :encoder

    # @param redis A Redis instance, or something that looks like Redis.
    # @param options [Hash] A set of options.
    #
    # @option :encoder [#decode, #encode, Symbol] Either one of the named encoders, or an object that responds to both +#encode+ and +#decode+. Defaults to :json.
    def initialize(redis = ::Redis.new, options={})
      @encoder = case options[:encoder]
                 when :messagepack, :msgpack
                   SimpleQueues::MessagePackEncoder.new
                 when :json, nil
                   SimpleQueues::JsonEncoder.new
                 when :identity
                   SimpleQueues::IdentityEncoder.new
                 else # Use whatever was provided
                   options[:encoder]
                 end
      raise ArgumentError, "Provided encoder #{@encoder.inspect} does not handle #encode and #decode" unless @encoder.respond_to?(:encode) && @encoder.respond_to?(:decode)

      @redis  = redis
      @queues = Hash.new
    end

    # Saves a block for later execution from #dequeue_with_timeout or #dequeue.
    #
    # When the block's arity is 1, only the message will be passed.
    # When the block's arity is 2, the queue's name and the message will be passed along, in that order.
    # When the block's arity is negative (accepts a variable number of arguments), SimpleQueues::Redis behaves as if the block's arity was 2.
    def on_dequeue(queue_name, &block)
      raise ArgumentError, "The provided block must accept at least one argument - #{block.inspect} accepts no arguments" if block.arity.zero?
      @queues[q_name(queue_name)] = block
    end

    def encode(message)
      raise ArgumentError, "message must be non-nil" if message.nil?
      encoder.encode(message)
    end

    def decode(message)
      encoder.decode(message) if message
    end

    # Enqueues a new message to the Redis backend.
    #
    # @param queue_name [String, Symbol] The queue name, which must not be nil or the empty String.
    # @param message [#to_s] The message to be enqueued. The message will be turned into a String through #to_s before being enqueued. Must not be nil, but the empty string is accepted, although it seems meaningless to do so.
    # @return [String] The encoded message.
    # @raise ArgumentError Whenever the queue name or the message are nil, or the queue name is empty.
    def enqueue(queue_name, message)
      raise ArgumentError, "Only hashes are accepted as messages" unless message.is_a?(Hash)

      encoded_message = encode(message)
      @redis.rpush(q_name(queue_name), encoded_message)
      encoded_message
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

        queue, result = @redis.blpop(*[@queues.keys, timeout.to_i].flatten)
        if queue then
          block = @queues.fetch(queue)
          message = decode(result)

          if block.arity == 1 then
            block.call(message)
          else
            block.call(queue, message)
          end
        end
        queue
      when 2
        queue_name, timeout = args.shift, args.shift
        _, result = @redis.blpop(q_name(queue_name), timeout.to_i)
        decode(result)
      else
        raise ArgumentError, "Expected 1 (timeout) or 2 (queue name, timeout) arguments, not #{args.length}"
      end
    end

    protected

    def q_name(queue_name)
      queue_name &&= queue_name.to_s
      raise ArgumentError, "Queue name argument was nil - must not be" if queue_name.nil? || queue_name.empty?
      queue_name
    end
  end
end

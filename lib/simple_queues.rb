# A simple API for queueing and dequeueing messages.
#
# In the Gang of Four book, the phrase "Program to an interface, not an implementation" made me think I shouldn't
# bind my software directly to Redis, but to an API from which I could change the implementation at any time. If
# I ever need to replace Redis with RabbitMQ, it will be possible to do so, given my software is coded to this
# interface.
#
# All SimpleQueues implementations support three methods:
# * +enqueue+
# * +dequeue_with_timeout+
# * +dequeue_blocking+
module SimpleQueues
  autoload :Redis, "simple_queues/redis"
end

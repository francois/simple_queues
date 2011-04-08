require "spec_helper"

describe SimpleQueues::Redis, "dequeue_blocking" do
  let :redis do
    double("redis")
  end

  let :queue do
    SimpleQueues::Redis.new(redis)
  end

  it "request indefinitely at the Redis layer" do
    redis.should_receive(:blpop).with("pages_to_crawl", 0)
    queue.dequeue_blocking("pages_to_crawl")
  end

  it "accepts symbols as queue names and translates them to strings" do
    redis.should_receive(:blpop).with("pages_to_crawl", 0)
    queue.dequeue_blocking(:pages_to_crawl)
  end

  it "raises an ArgumentError when the queue name is nil or empty" do
    lambda { queue.dequeue_blocking(nil) }.should raise_error(ArgumentError)
    lambda { queue.dequeue_blocking("") }.should raise_error(ArgumentError)
  end

  it "should reraise underlying connection errors"
  # Errno::ECONNREFUSED
  # Errno::EAGAIN

  context "given #exception_handler= is set with a block" do
    it "should call the block to handle underlying connection exceptions"
  end
end

describe SimpleQueues::Redis, "dequeue_with_timeout" do
  let :redis do
    double("redis")
  end

  let :encoder do
    double("encoder").as_null_object
  end

  let :queue do
    SimpleQueues::Redis.new(redis, :encoder => encoder)
  end

  it "should call Redis' BLPOP with the requested timeout" do
    redis.should_receive(:blpop).with("pages_to_crawl", 42)
    queue.dequeue_with_timeout(:pages_to_crawl, 42)
  end

  it "accepts symbols as queue names and translates them to strings" do
    redis.should_receive(:blpop).with("pages_to_crawl", 5)
    queue.dequeue_with_timeout(:pages_to_crawl, 5)
  end

  it "raises an ArgumentError when the queue name is nil or empty" do
    lambda { queue.dequeue_with_timeout(nil) }.should raise_error(ArgumentError)
    lambda { queue.dequeue_with_timeout("") }.should  raise_error(ArgumentError)
  end

  it "should decode the message using the selected encoder" do
    encoded_message = '{"hello":"world","x":42}'

    redis.should_receive(:blpop).with("test", 5).and_return(["test", encoded_message])
    encoder.should_receive(:decode).with(encoded_message).and_return("hello" => "world", "x" => 42)

    queue.dequeue_with_timeout(:test, 5)
  end
end

require "spec_helper"

describe SimpleQueues::Redis, "dequeue_blocking" do
  let :redis do
    double("redis")
  end

  let :queue do
    SimpleQueues::Redis.new(redis)
  end

  it "requests an infinite timeout from Redis #blpop" do
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
end

describe SimpleQueues::Redis, "dequeue_with_timeout" do
  let :redis do
    double("redis")
  end

  let :queue do
    SimpleQueues::Redis.new(redis)
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
    lambda { queue.dequeue_with_timeout("") }.should raise_error(ArgumentError)
  end
  
  it "returns the unserialized object" do
    redis.should_receive(:blpop).with("test", 5).and_return(["test", "{\"hello\":\"world\",\"x\":42}"] )
    queue.dequeue_with_timeout(:test, 5).should == {"hello" => "world", "x" => 42}
  end
end

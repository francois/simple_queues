require "spec_helper"

describe SimpleQueues::Redis, "enqueue" do
  let :redis do
    double("redis")
  end

  let :queue do
    SimpleQueues::Redis.new(redis)
  end

  it "should enqueue to the end of the list" do
    redis.should_receive(:rpush).with("q", "message")
    queue.enqueue("q", "message")
  end

  it "should reject invalid queue names" do
    lambda { queue.enqueue(nil, "") }.should raise_error(ArgumentError)
    lambda { queue.enqueue("", "") }.should raise_error(ArgumentError)
  end

  it "should reject nil messages" do
    lambda { queue.enqueue(:a, nil) }.should raise_error(ArgumentError)
  end

  it "should allow blank messages (although does this make sense?)" do
    redis.should_receive(:rpush)
    lambda { queue.enqueue(:a, "") }.should_not raise_error
  end

  it "accepts symbols as queue names, translating to a string" do
    redis.should_receive(:rpush).with("pages_to_crawl", "http://blog.teksol.info/")
    queue.enqueue :pages_to_crawl, "http://blog.teksol.info/"
  end

  it "translates the message to a String before enqueueing" do
    redis.should_receive(:rpush).with("ops", "shutdown_and_destroy")
    queue.enqueue :ops, :shutdown_and_destroy
  end
end

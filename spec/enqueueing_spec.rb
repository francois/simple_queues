require "spec_helper"

describe SimpleQueues::Redis, "enqueue" do
  let :redis do
    double("redis")
  end

  let :encoder do
    double("encoder").as_null_object
  end

  let :queue do
    SimpleQueues::Redis.new(redis, :encoder => encoder)
  end

  it "should enqueue using the passed-in queue name" do
    redis.should_receive(:rpush).with("the_queue", anything)
    queue.enqueue "the_queue", {}
  end

  it "should accept symbols as queue names, translating to a string" do
    redis.should_receive(:rpush).with("pages_to_crawl", anything)
    queue.enqueue :pages_to_crawl, :url => "http://blog.teksol.info/"
  end

  it "should enqueue the encoded message" do
    encoded_message = "jfd9jdf"

    encoder.should_receive(:encode).and_return(encoded_message)
    redis.should_receive(:rpush).with(anything, encoded_message)

    queue.enqueue("q", :key => "value")
  end

  it "should return the encoded message" do
    encoded_message = "barfly123"
    encoder.should_receive(:encode).and_return(encoded_message)
    redis.should_receive(:rpush)

    queue.enqueue("q", {:message => "whatever"}).should == encoded_message
  end

  it "should raise an ArgumentError when the message isn't a Hash" do
    lambda { queue.enqueue(:q, 42)      }.should raise_error(ArgumentError, "Only hashes are accepted as messages")
    lambda { queue.enqueue(:q, nil)     }.should raise_error(ArgumentError, "Only hashes are accepted as messages")
    lambda { queue.enqueue(:q, "")      }.should raise_error(ArgumentError, "Only hashes are accepted as messages")
    lambda { queue.enqueue(:q, [1,2,3]) }.should raise_error(ArgumentError, "Only hashes are accepted as messages")
  end

  it "should reject invalid queue names" do
    lambda { queue.enqueue(nil, "") }.should raise_error(ArgumentError)
    lambda { queue.enqueue("", "") }.should raise_error(ArgumentError)
  end

  it "should encode the message using the provided encoder" do
    message = {:a => "b"}
    encoded_message = 'hfd0hs'

    encoder.should_receive(:encode).with(message).and_return(encoded_message)
    redis.should_receive(:rpush)

    queue.enqueue :q, message
  end
end

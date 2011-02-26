require "spec_helper"

describe SimpleQueues::Redis, "enqueue" do
  let :queue do
    SimpleQueues::Redis.new
  end

  it "communicates with Redis as expected" do
    obj = {"hello" => 42}
    queue.enqueue(:test, obj)
    queue.dequeue_with_timeout(:test, 2).should == obj
    queue.dequeue_with_timeout(:test, 2).should == nil
  end

  it "clears the queue" do
    queue.enqueue(:test, 42)
    queue.clear(:test)
    queue.dequeue_with_timeout(:test, 1).should == nil
  end

  it "returns the queue size" do
    queue.clear(:test)
    queue.enqueue(:test, 42)
    queue.enqueue(:test, 42)
    queue.enqueue(:test, 42)
    queue.enqueue(:test, 42)
    queue.size(:test).should == 4
  end
end
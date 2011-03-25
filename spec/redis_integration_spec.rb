require "spec_helper"
require "redis"

describe SimpleQueues::Redis do
  let :queue_name do
    :test
  end

  let :redis do
    ::Redis.new
  end

  let :queue do
    SimpleQueues::Redis.new(redis)
  end

  before(:each) do
    redis.flushdb
  end

  context "given an empty queue" do
    context "#size" do
      it { queue.size(queue_name).should == 0 }
    end

    context "#clear" do
      it { lambda { queue.clear(queue_name) }.should_not raise_error }
    end

    context "#dequeue_with_timeout" do
      it { queue.dequeue_with_timeout(queue_name, 1).should == nil }
    end
  end

  context "given a queue with one message" do
    let :message do
      { "value" => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S") }
    end

    before(:each) do
      queue.enqueue(queue_name, message)
    end

    context "#size" do
      it { queue.size(queue_name).should == 1 }
    end

    context "#dequeue_with_timeout" do
      it { queue.dequeue_with_timeout(queue_name, 1).should == message }
    end

    context "#clear" do
      before(:each) do
        queue.clear(queue_name)
      end

      it "should remove all waiting messages" do
        queue.size(queue_name).should == 0
      end
    end
  end
end

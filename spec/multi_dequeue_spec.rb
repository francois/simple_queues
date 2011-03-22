require 'spec_helper'

describe SimpleQueues::Redis, "multiple dequeue" do
  let :queue do
    SimpleQueues::Redis.new
  end

  let :redis do
    Redis.new
  end

  before(:each) do
    redis.flushdb
  end

  it "should accept setting up a dequeue block" do
    lambda do
      queue.on_dequeue(:pages_to_crawl) {|message| message}
    end.should_not raise_error
  end

  it "should accept setting up multiple dequeue block" do
    lambda do
      queue.on_dequeue(:pages_to_crawl)   {|message| message}
      queue.on_dequeue(:pages_to_analyze) {|message| message}
    end.should_not raise_error
  end

  context "#dequeue_with_timeout" do
    it "should return the queue name when a message was dequeued" do
      queue.on_dequeue(:a) {|message| message}
      queue.on_dequeue(:b) {|message| raise "not here"}
      queue.enqueue(:a, :sent_to => "a")
      queue.dequeue_with_timeout(1).should == "a"
    end

    it "should return nil when no queues returned anything" do
      queue.on_dequeue(:a) {|message| raise "not here"}
      queue.dequeue_with_timeout(1).should be_nil
    end

    it "should call into the correct block" do
      a, b = [], []
      queue.on_dequeue(:a) {|message| a << message}
      queue.on_dequeue(:b) {|message| b << message}

      queue.enqueue(:a, "sent_to" => "a", "serial" => 1)
      queue.enqueue(:b, "sent_to" => "b", "serial" => 1)
      queue.enqueue(:a, "sent_to" => "a", "serial" => 2)
      while queue.dequeue_with_timeout(1)
        # NOP
      end

      a.should == [{"sent_to" => "a", "serial" => 1}, {"sent_to" => "a", "serial" => 2}]
      b.should == [{"sent_to" => "b", "serial" => 1}]
    end
  end
end

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

  context "#on_dequeue" do
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

    it "should raise an ArgumentError when the block accepts no arguments" do
      lambda { queue.on_dequeue(:a) { fail } }.should raise_error(ArgumentError)
    end
  end

  context "#dequeue_with_timeout" do
    it "should return the queue name where the message was dequeued" do
      queue.on_dequeue(:a) {|message| message}
      queue.on_dequeue(:b) {|message| raise "not here"}
      queue.enqueue(:a, :sent_to => "a")
      queue.dequeue_with_timeout(1).should == "a"
    end

    it "should return nil when no messages were pending" do
      queue.on_dequeue(:a) {|message| raise "not here"}
      queue.dequeue_with_timeout(1).should be_nil
    end

    it "should send only the message when the block has an arity of 1" do
      a, b = [], []
      queue.on_dequeue(:a) {|message| a << message}
      queue.on_dequeue(:b) {|message| b << message}

      queue.enqueue(:a, "sent_to" => "a", "serial" => 1)
      queue.enqueue(:b, "sent_to" => "b", "serial" => 1)
      queue.enqueue(:a, "sent_to" => "a", "serial" => 2)

      3.times { queue.dequeue_with_timeout(1) }

      a.should == [{"sent_to" => "a", "serial" => 1}, {"sent_to" => "a", "serial" => 2}]
      b.should == [{"sent_to" => "b", "serial" => 1}]
    end

    it "should send the queue name and the message when the block has an arity of 2" do
      received = []
      queue.on_dequeue(:a) {|queue, message| received << [queue, message]}
      queue.on_dequeue(:b) {|queue, message| received << [queue, message]}

      queue.enqueue(:a, "a" => 1)
      queue.enqueue(:b, "b" => 2)

      2.times { queue.dequeue_with_timeout(1) }

      received.should == [["a", {"a" => 1}], ["b", {"b" => 2}]]
    end

    it "should send the queue name and the message when the block has an arity of -1" do
      received = []
      queue.on_dequeue(:a) {|*args| received << args}
      queue.on_dequeue(:b) {|*args| received << args}

      queue.enqueue(:a, "a" => 1)
      queue.enqueue(:b, "b" => 2)

      2.times { queue.dequeue_with_timeout(1) }

      received.should == [["a", {"a" => 1}], ["b", {"b" => 2}]]
    end

    it "should send the queue name and the message when the block has an arity of -2" do
      received = []
      queue.on_dequeue(:a) {|queue, *args| received << [queue, args]}
      queue.on_dequeue(:b) {|queue, *args| received << [queue, args]}

      queue.enqueue(:a, "a" => 1)
      queue.enqueue(:b, "b" => 2)

      2.times { queue.dequeue_with_timeout(1) }

      received.should == [["a", [{"a" => 1}]], ["b", [{"b" => 2}]]]
    end
  end
end

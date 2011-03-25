require 'spec_helper'

describe SimpleQueues::Redis, "#initialize" do
  it "should default to the JSON encoder" do
    subject.encoder.should be_a(SimpleQueues::JsonEncoder)
  end

  it "should use the MessagePack encoder when passing :encoder => :messagepack" do
    SimpleQueues::Redis.new(double("redis"), :encoder => :msgpack).encoder.should be_a(SimpleQueues::MessagePackEncoder)
  end

  it "should use the MessagePack encoder when passing :encoder => :messagepack" do
    SimpleQueues::Redis.new(double("redis"), :encoder => :messagepack).encoder.should be_a(SimpleQueues::MessagePackEncoder)
  end

  it "should use the Identity encoder when passing :encoder => :identity" do
    SimpleQueues::Redis.new(double("redis"), :encoder => :identity).encoder.should be_a(SimpleQueues::IdentityEncoder)
  end

  it "should use the JSON encoder when passing :encoder => :json" do
    SimpleQueues::Redis.new(double("redis"), :encoder => :json).encoder.should be_a(SimpleQueues::JsonEncoder)
  end

  it "should use whatever encoder is sent" do
    encoder = double("encoder", :encode => nil, :decode => nil)
    SimpleQueues::Redis.new(double("redis"), :encoder => encoder).encoder.should be(encoder)
  end
end

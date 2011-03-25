require 'spec_helper'
require 'msgpack'

describe SimpleQueues::MessagePackEncoder do
  it { should encode("a" => "b").as(MessagePack.pack("a" => "b")) }
  it { should decode({"a" => "b"}.to_msgpack).as("a" => "b") }

  it "stringifies Symbol keys" do
    message = {:a => "b"}
    encoded_message = subject.encode(message)
    decoded_message = subject.decode(encoded_message)
    decoded_message.should == {"a" => "b"}
  end
end

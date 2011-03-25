require 'spec_helper'
require 'json'

describe SimpleQueues::JsonEncoder do
  it { should encode("a" => "b").as(JSON("a" => "b"))     }
  it { should decode({"a" => "b"}.to_json).as("a" => "b") }

  it "stringifies Symbol keys" do
    message = {:a => "b"}
    encoded_message = subject.encode(message)
    decoded_message = subject.decode(encoded_message)
    decoded_message.should == {"a" => "b"}
  end
end

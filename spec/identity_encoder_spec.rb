require 'spec_helper'

describe SimpleQueues::IdentityEncoder do
  it { should encode(a:1, b:2, c:"3").as(a:1, b:2, c:"3") }
  it { should decode(a:1, b:2, c:"3").as(a:1, b:2, c:"3") }

  it "should not stringify symbol keys" do
    message = {:a => "b"}
    encoded_message = subject.encode(message)
    decoded_message = subject.decode(encoded_message)
    decoded_message.should == {:a => "b"}
  end
end

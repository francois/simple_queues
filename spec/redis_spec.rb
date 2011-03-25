require 'spec_helper'

describe SimpleQueues::Redis do
  it "should default to the JSON encoder" do
    subject.encoder.should be_a(SimpleQueues::JsonEncoder)
  end
end

require "simple_queues"

class DecoderMatcher
  def initialize(message)
    @message = message
  end

  def as(expected)
    @expected = expected
    self
  end

  def matches?(decoder)
    @actual = decoder.decode(@message)
    @expected == @actual
  end

  def failure_message_for_should
    "expected decoded message <#{@actual.inspect} to equal <#{@expected.inspect}>"
  end

  def description
    "decode #{@message.inspect}"
  end
end

def decode(message)
  DecoderMatcher.new(message)
end

class EncoderMatcher
  def initialize(message)
    @message = message
  end

  def as(expected)
    @expected = expected
    self
  end

  def matches?(encoder)
    @actual = encoder.encode(@message)
    @expected == @actual
  end

  def failure_message_for_should
    "expected encoded message <#{@actual.inspect} to equal <#{@expected.inspect}>"
  end

  def description
    "encode #{@message.inspect}"
  end
end

def encode(message)
  EncoderMatcher.new(message)
end

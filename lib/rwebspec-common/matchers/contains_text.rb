class ContainsText

  # this is what the matcher is called on.
  # In this case:
  #   foo.should contains(:bars)
  # foo would be passed to the +initialize+
  def initialize(expected)
    @expected = expected
  end

  def matches?(actual)
    @actual = actual
    return actual && actual.include?(@expected)
  end

  def actual_text
    @actual.to_s.length > 256 ? @actual[0, 255] : @actual
  end

  # error message for should
  def failure_message
    "expected '#{actual_text}' to contain '#{@expected}', but it didn't"
  end

  # error message for should_not
  def negative_failure_message
    "expected '#{actual_text}' not to contain '#{@expected}', but it did"
  end

end


# This method is the one you use with should/should_not
def contains_text?(expected)
  ContainsText.new(expected)
end
alias contains? contains_text?
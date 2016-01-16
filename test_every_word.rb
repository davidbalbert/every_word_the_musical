require 'minitest/autorun'

require './every_word'

class EveryWordTest < Minitest::Test
  def self.test(name, &block)
    method_name = "test_#{name.downcase.gsub(/\s+/, '_')}"
    define_method(method_name, &block)
  end
end

class NewTweetTest < EveryWordTest
  test "the body is correct" do
    assert_equal 'Foo the Musical!', NewTweet.new('foo').body
  end
end

class ExistingTweetTest < EveryWordTest
  test "the word is correct" do
    assert_equal 'bar', ExistingTweet.new('Bar the Musical!').word
  end

  test "parse error" do
    assert_raises(ExistingTweet::ParseError) do
      ExistingTweet.new('foo bar baz')
    end
  end
end

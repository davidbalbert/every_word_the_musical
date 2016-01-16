require 'logger'
require 'syslog/logger'

require 'twitter'
require 'dotenv'

class Dictionary
  PATH = './words'

  class WordNotFound < StandardError; end

  attr_accessor :words, :pos

  def initialize
    @words = File.readlines(PATH).map { |w| w.chomp.downcase }
    @pos = 0
  end

  def skip_through(word)
    i = words.index(word)

    if i
      @pos = i + 1
    else
      raise WordNotFound, "cannot find \"#{word}\""
    end
  end

  def next
    w = words[pos]

    if w
      @pos += 1
    end

    w
  end
end

class NewTweet
  attr_reader :word

  def initialize(word)
    @word = word
  end

  def body
    "#{@word.capitalize} the Musical!"
  end
end

class ExistingTweet
  class ParseError < StandardError; end

  attr_reader :body, :word

  def initialize(body)
    @body = body

    if @body =~ /(.+) the Musical/
      @word = $1.downcase
    else
      raise ParseError, "cannot parse \"#{body}\""
    end
  end
end

class EveryWord
  attr_reader :dict, :logger, :client

  def initialize
    @dict = Dictionary.new

    if production?
      @logger = Syslog::Logger.new
    else
      @logger = Logger.new(STDOUT)
    end

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['CONSUMER_KEY']        or raise 'missing consumer key'
      config.consumer_secret     = ENV['CONSUMER_SECRET']     or raise 'missing consumer secret'
      config.access_token        = ENV['ACCESS_TOKEN']        or raise 'missing access token'
      config.access_token_secret = ENV['ACCESS_TOKEN_SECRET'] or raise 'missing access token secret'
    end
  end

  def production?
    ENV['EVERY_WORD_ENV'] == 'production'
  end

  def tweet
    begin
      recover_position
      send_tweet
    rescue => e
      error format_exception(e)
    end
  end

  private

  def recover_position
    t = last_tweet

    if t.nil?
      info 'no previous tweets; starting from beginning'
      return
    end

    word = last_word(t)

    if word.nil?
      info "couldn't parse tweet \"#{t.text}\"; starting from beginning"
      return
    end

    dict.skip_through(word)
    debug "tweet found; skipping through \"#{word}\""
  end

  def last_word(tweet)
    ExistingTweet.new(tweet.text).word
  rescue ExistingTweet::ParseError
    nil
  end

  def last_tweet
    client.user_timeline(count: 1).first
  end

  def send_tweet
    word = dict.next

    if word.nil?
      info 'no more tweets'
      return
    end

    t = NewTweet.new(word)
    client.update(t.body)
    info "tweeted \"#{t.body}\""
  end

  def format_exception(e)
    "#{e.class}: #{e.message}\n  " + e.backtrace.join("\n  ")
  end

  def info(s)
    logger.info s
  end

  def debug(s)
    logger.debug s
  end

  def error(s)
    logger.error s
  end
end

if __FILE__ == $0
  Dotenv.load
  EveryWord.new.tweet
end

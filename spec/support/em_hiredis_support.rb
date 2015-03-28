# adapted from em-hiredis/spec/support/redis.rb, thanks!
require "socket"

module EmHiredisSupport

  class RedisMock

    attr_reader :call_count
    attr_reader :last

    def initialize(replies)
      @replies = replies
      @last = { :command => nil, :args => nil }
      @call_count = 0
    end

    def method_missing(command, *args, &block)
      @call_count += 1
      @last[:command] = command
      @last[:args] = args

      result = (@replies[command] || lambda { |*_| "+OK" }).call(*args)
      if block_given?
        yield result
      end
    end
  end

  module Helper
    def em_hiredis_mock(replies = {}, &block)
      redis = RedisMock.new(replies)
      if block_given?
        yield redis
      else
        redis
      end
    end
  end
end

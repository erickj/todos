# adapted from em-hiredis/spec/support/redis.rb, thanks!
require "socket"

module EmHiredisSupport

  class RedisMock

    def initialize(replies)
      @replies = replies
    end

    def method_missing(command, *args, &block)
      yield (@replies[command] || lambda { |*_| "+OK" }).call(*args)
    end
  end

  module Helper
    def em_hiredis_mock(replies = {}, &block)
      yield RedisMock.new replies
    end
  end
end

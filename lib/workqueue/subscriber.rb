module WorkQueue
  module Subscriber
    include Logging

    attr_writer :pubsub_redis

    def subscribe(channel, &block)
      log.info 'subscribing to channel %s' % channel

      # there seems to be a bug in em-redis, where subscribing to symbols
      # doesn't work correctly, i'm guessing there is a problem w/ receiving
      # messages and not canonicalizing channel names. instead explicitly
      # convert channel to string
      @pubsub_redis.pubsub.subscribe(channel.to_s, &block).callback do |result|
        log.info 'subscribed to channel %s' % channel
      end
    end
  end
end

module WorkQueue
  module Publisher

    attr_writer :pubsub_redis

    def publish(channel, msg)
      raise RuntimeError, 'redis instance not set, did you call +pubsub_redis=+' unless @pubsub_redis
      @pubsub_redis.publish pubsub_validate_channel(channel), pubsub_validate_message(msg)
    end

    private
    def pubsub_validate_channel(channel)
      raise ArgumentError, 'channel should be a symbol' unless channel.is_a? Symbol
      channel
    end

    def pubsub_validate_message(message)
      raise ArgumentError, 'message should be a string' unless message.is_a? String
      message
    end
  end
end

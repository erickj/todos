module WorkQueue
  module RedisConsumer

    # TODO(erick): add event handlers for monitoring the connection state of
    # redis and hooks for including modules/classes to use instead of the hacky
    # overriding +redis=+ I do now.
    attr_accessor :redis
  end
end

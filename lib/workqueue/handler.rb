module WorkQueue

  # Emits the following events:
  #
  # * handle_tick_begin(Time.now) - before handling each tick
  # * handle_tick_end(Time.now) - upon completing handling each tick
  class Handler
    include EventEmitter
    include Publisher
    include Logging

    SUCCESS = EM::DefaultDeferrable.new
    SUCCESS.succeed

    FAILURE = EM::DefaultDeferrable.new
    FAILURE.fail

    attr_reader :redis

    def redis=(redis)
      @redis = redis
      self.pubsub_redis = redis
    end

    def handle_tick
#      log.debug "handle tick"
      emit(:handle_tick_begin, Time.now)
      result = handle_tick_internal
      emit(:handle_tick_end, Time.now)
      result
    end

    protected
    def task_serializer
      TaskSerializer.instance
    end

    def handle_tick_internal
      SUCCESS
    end
  end
end

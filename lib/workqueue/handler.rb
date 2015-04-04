module WorkQueue

  # Emits the following events:
  #
  # * handle_tick_begin(Time.now) - before handling each tick
  # * handle_tick_end(Time.now) - upon completing handling each tick
  class Handler
    include EventEmitter
    include Publisher
    include Logging

    attr_reader :redis

    def redis=(redis)
      @redis = redis
      self.pubsub_redis = redis
    end

    def handle_tick
      emit(:handle_tick_begin, Time.now)
      result = handle_tick_internal
      emit(:handle_tick_end, Time.now)

      result.is_a?(EM::Deferrable) ?
        result :
        create_deferred_result(!!result)
    end

    protected
    def task_serializer
      TaskSerializer.instance
    end

    # Returns either a boolean or a deferred. If if a deferred is returned then
    # +handle_tick+ returns the deferred directly. Otherwise if a boolean is
    # returned then true indicates success or false for failure. This will be
    # converted to the relevant deferred response.
    def handle_tick_internal
      create_deferred_result
    end

    private
    def create_deferred_result(is_success=true, error_reason=:nodata)
      result = EM::DefaultDeferrable.new
      is_success ? result.succeed : result.fail(error_reason)
      result
    end
  end
end

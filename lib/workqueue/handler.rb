module WorkQueue

  # Emits the following events:
  #
  # * handle_tick_begin(Time.now) - before handling each tick
  # * handle_tick_end(Time.now) - upon completing handling each tick
  class Handler
    include EventEmitter
    include Publisher

    SUCCESS = EM::DefaultDeferrable.new
    SUCCESS.succeed

    FAILURE = EM::DefaultDeferrable.new
    FAILURE.fail

    attr_accessor :redis

    def handle_tick
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

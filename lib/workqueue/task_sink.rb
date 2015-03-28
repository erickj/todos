module WorkQueue
  class TaskSink

    # Reads serialized +Task+ objects off of a redis queue. Calls to
    # redis are scheduled via calls to +handle_tick+. Normally calls
    # to +handle_tick+ will be scheduled via a WQ::Runner.
    def initialize(queue_name, task_serializer=TaskSerializer.instance, &handler)
      @task_serializer = task_serializer
      @queue_name = queue_name
      @handler = handler
    end

    def handle_tick(redis)
    end

  end
end

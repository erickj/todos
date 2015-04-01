module WorkQueue
  class TaskSink < Handler

    # Reads serialized +Task+ objects off of a redis queue. Calls to
    # redis are scheduled via calls to +handle_tick+. Normally calls
    # to +handle_tick+ will be scheduled via a WQ::Runner.
    def initialize(queue_name, &task_handler)
      @queue_name = queue_name
      @task_handler = block_given? ? task_handler : nil
    end

    # override Handler#handle_tick_internal
    def handle_tick_internal
      deferred_result = EM::DefaultDeferrable.new
      redis.lpop(@queue_name) do |lpop_result|
        if lpop_result.nil?
          deferred_result.fail
        else
          process_raw_task_from_queue(lpop_result)
          deferred_result.succeed
        end
      end
      deferred_result
    end

    private
    def process_raw_task_from_queue(raw_task)
      task = task_serializer.deserialize(raw_task)
      raise ArgumentError, 'not a task' unless task.is_task?
      @task_handler.call(task) unless @task_handler.nil?
    end

  end
end

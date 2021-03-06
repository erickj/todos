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
          deferred_result.fail(:nodata)
        else
          process_raw_task_from_queue(lpop_result)
          deferred_result.succeed
        end
      end
      # The deferred_result only indicates whether the queue was empty, not
      # whether processing succeeded. If the queue is empty (deferred fails)
      # then the WQ::Runner will unschedule this sink for a few moments.
      deferred_result
    end

    private
    def process_raw_task_from_queue(raw_task)
      task = task_serializer.deserialize(raw_task)
      raise ArgumentError, 'not a task' unless task.is_task?
      task_result = @task_handler.call(task) unless @task_handler.nil?

      if task_result
        log.info 'publishing result %s to %s' % [task_result, WQ::TASK_RESULT_CHANNEL]
        publish(WQ::TASK_RESULT_CHANNEL, task_serializer.serialize(task_result))
      end
    end

  end
end

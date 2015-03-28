module WorkQueue

  # Pushes serialized +Task+ objects onto a redis queue. Calls to
  # redis are scheduled via calls to +handle_tick+. Normally calls to
  # TaskSource#handle_tick will be scheduled via a WorkQueue::Runner.
  class TaskSource

    SUCCESS = EM::DefaultDeferrable.new
    SUCCESS.succeed

    FAILURE = EM::DefaultDeferrable.new
    FAILURE.fail

    def initialize(queue_name, task_serializer=TaskSerializer.instance)
      @task_serializer = task_serializer
      @pending_queue = []
      @lock = Mutex.new
      @queue_name = queue_name
    end

    # Schedule a task for being added to the work queue
    def queue_task(task)
      unless task.respond_to? :work
        raise ArgumentError, "task must respond to :work"
      end

      @lock.synchronize do
        @pending_queue.push(@task_serializer.serialize(task))
      end
    end

    def handle_tick(redis)
      return FAILURE if @pending_queue.empty?

      tmp_queue = nil
      @lock.synchronize do
        tmp_queue = @pending_queue
        @pending_queue = []
      end

      until tmp_queue.empty?
        redis.rpush(@queue_name, tmp_queue.pop)
      end
      SUCCESS
    end
  end
end

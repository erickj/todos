module WorkQueue

  # Pushes serialized +Task+ objects onto a redis queue. Calls to
  # redis are scheduled via calls to +handle_tick+. Normally calls to
  # TaskSource#handle_tick will be scheduled via a WorkQueue::Runner.
  class TaskSource < Handler

    def initialize(queue_name)
      @pending_queue = []
      @lock = Mutex.new
      @queue_name = queue_name
    end

    def empty?
      @pending_queue.empty?
    end

    # Schedule a task for being added to the work queue
    def queue_task(task)
      unless task.is_task?
        raise ArgumentError, "task must respond true to :is_task?"
      end

      @lock.synchronize do
        @pending_queue.push(task_serializer.serialize(task))
      end
    end
    alias :<< :queue_task

    # override Handler#handle_tick_internal
    def handle_tick_internal
      return false if @pending_queue.empty?

      tmp_queue = nil
      @lock.synchronize do
        tmp_queue = @pending_queue
        @pending_queue = []
      end

      until tmp_queue.empty?
        redis.rpush(@queue_name, tmp_queue.pop)
      end
      true
    end
  end
end

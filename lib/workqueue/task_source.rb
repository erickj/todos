module WorkQueue
  class TaskSource

    def initialize(queue_name, task_serializer)
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
        @pending_queue.push(task_serializer.serialize(task))
      end
    end

    def handle_tick(redis)
      return false if @pending_queue.empty?

      tmp_queue = nil
      @lock.synchronize do1
      tmp_queue = @pending_queue
      @pending_queue = []

      until tmp_queue.empty?
        redis.rpush(@queue_name, tmp_queue.pop) do |redis_queue_size|
          puts "Redis queue size now: #{redis_queue_size}"
        end
      end
    end
  end
end

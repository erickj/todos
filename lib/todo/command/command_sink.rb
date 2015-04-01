require 'workqueue'

module Todo::Command

  # Emits events:
  #
  # * :process_command_begin(Time.now)
  # * :process_command_end(Time.now)
  # * :process_command_result(UUID, Task)
  class CommandSink < WQ::TaskSink

    def initialize
      super(QUEUE_NAME, &method(:process_command))
    end

    private
    def process_command(task)
      emit :process_command_begin, Time.now

      processor = case task.task_type
                  when Todo::Command::TaskType::CREATE_TODO
                    CreateTodo::Processor.new
                  when Todo::Command::TaskType::NOOP_TODO
                    Class.new do
                      include Todo::Command::Processor
                      processes TaskType::NOOP_TODO
                      def process_command_internal(*_); end
                    end.new
                  else
                    raise ArgumentError, 'unknown task type %s'%task.task_type
                  end

      task_result = processor.process_command(task)
      emit :process_command_end, Time.now

      publish(:todo_command_results, task_serializer.serialize(task_result))
    end

  end
end

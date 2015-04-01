require 'workqueue/task_sink'

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
    def process_command(command_task)
      emit :process_command_begin, Time.now

      processor = nil
      case command_task
      when TaskType::CREATE_TODO
        processor = CreateTodo::Processor.new
      else
        raise ArgumentError, 'unknown task type'
      end

      model = processor.process(task)
      emit :process_command_end, Time.now
      emit :process_command_result, CommandResult.new(model.uuid, task)
    end

  end
end

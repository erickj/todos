require 'workqueue/task_sink'

module Todo::Command
  class CommandSink < WQ::TaskSink

    def initialize(task_serializer=TaskSerializer.instance)
      super(QUEUE_NAME, task_serializer, &method(:process_command))
    end

    private
    def process_command(command_task)
      processor = nil
      case command_task
      when TaskType::CREATE_TODO
        processor = CreateTodoCommandProcessor.new
      # when TaskType::UPDATE_TODO
      #   processor = UpdateTodoCommandProcessor.new
      # when TaskType::DELETE_TODO
      #   processor = DeleteTodoCommandProcessor.new
      else
        raise ArgumentError, 'unknown task type'
      end

      processor.process(task)
    end
  end
end

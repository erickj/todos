require 'workqueue/task_sink'

module Todo::Command

  # Emits events:
  #
  # * :command_complete
  class CommandSink < WQ::TaskSink

    def initialize
      super(QUEUE_NAME, &method(:process_command))
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

      process_op = lambda do |*_|
        processor.process(task).uuid
      end
      EM.defer process_op, &method(:handle_processing_complete).to_proc.curry(task)
    end

    def handle_processing_complete(task, uuid)
      emit :command_complete, CommandResult.new(uuid, task)
    end
  end
end

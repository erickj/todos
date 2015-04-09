require 'workqueue'

module Todo::Command

  # Emits events:
  #
  # * :process_command_begin(Time.now)
  # * :process_command_end(Time.now)
  # * :process_command_result(UUID, Task)
  class CommandSink < WQ::TaskSink

    include Logging

    def initialize
      super(QUEUE_NAME, &method(:process_command))
    end

    private
    def process_command(task)
      log.info { "processing command: %s" % task }
      emit :process_command_begin, Time.now

      task_result = Processor.processor_for(task).process_command task

      emit :process_command_end, Time.now
      task_result
    end

  end
end

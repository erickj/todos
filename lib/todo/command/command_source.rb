require 'workqueue/task_source'

module Todo::Command
  class CommandSource < WQ::TaskSource
    def initialize
      super QUEUE_NAME
    end
  end
end

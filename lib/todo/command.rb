module Todo
  module Command
    QUEUE_NAME = :todo_command_queue
  end
end

require 'todo/command/task_type'
require 'todo/command/create_todo_command'
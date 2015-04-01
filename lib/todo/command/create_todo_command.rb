require 'workqueue/task'
require 'todo/model'

module Todo
  module Command
    module CreateTodo

      class Command
        include WorkQueue::TaskMixin

        task_type TaskType::CREATE_TODO

        field(:owner_email)
          .required
          .type String

        field(:title)
          .required
          .type String

        field(:description)
          .type String
      end

      class Processor
        include Todo::Command::Processor

        processes TaskType::CREATE_TODO

        # overrides
        protected
        def process_command_internal(command)
          owner = Model::Person.first_or_create(:email => command.owner_email)

          fields = command.to_h
          fields.delete :owner_email
          fields[:owner] = owner
          Model::TodoTemplate.create(fields)
        end
      end
    end
  end
end

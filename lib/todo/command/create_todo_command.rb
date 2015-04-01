require 'workqueue/task'
require 'todo/model'

module Todo
  module Command
    module CreateTodo
      class Command
        include WorkQueue::TaskMixin

        task_type TaskType::CREATE_TODO

        attr_reader :owner_email
        attr_reader :title
        attr_reader :description

        def self.build(owner_email, title, description)
          command = self.new

          command.instance_variable_set(:"@owner_email", owner_email)
          command.instance_variable_set(:"@title", title)
          command.instance_variable_set(:"@description", description)

          command
        end
      end

      class Processor
        include Todo::Command::Processor

        processes TaskType::CREATE_TODO

        # overrides
        protected
        def process_command_internal(command)
          owner = Model::Person.first_or_create(:email => command.owner_email)

          Model::TodoTemplate.create({
                                       :title => command.title,
                                       :description => command.description,
                                       :owner => owner
                                     })
        end
      end
    end
  end
end

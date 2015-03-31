require 'workqueue/task'
require 'model'

module Todo
  module Command
    class CreateTodoCommand
      include WorkQueue::TaskMixin

      attr_reader :owner_email
      attr_reader :title
      attr_reader :description

      def initialize
        @task_type = TaskType::CREATE_TODO
      end

      def self.build(owner_email, title, description)
        command = self.new

        command.instance_variable_set(:"@owner_email", owner_email)
        command.instance_variable_set(:"@title", title)
        command.instance_variable_set(:"@description", description)

        command
      end
    end

    class CreateTodoCommandProcessor

      def process(task)
        unless task =~ TaskType::CREATE_TODO
          raise ArgumentError, 'not a create command'
        end

        task_owner = Model::Person.first_or_create(:email => task.owner_email)

        Model::TodoTemplate.create({
          :title => task.title,
          :description => task.description,
          :owner => task_owner
        })
      end
    end
  end
end

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

        field(:collaborator_emails)
          .default([])
          .collection_of String

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
          fields = command.to_h

          owner = Model::Person.first_or_create(:email => command.owner_email)
          fields.delete :owner_email
          fields[:owner] = owner

          fields[:collaborators] = []
          command.collaborator_emails.each do |collab_email|
            fields[:collaborators] << Model::Person.first_or_create(:email => collab_email)
          end
          fields.delete :collaborator_emails

          Model::TodoTemplate.create(fields)
        end
      end
    end
  end
end

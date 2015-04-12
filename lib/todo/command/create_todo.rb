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

          new_users = []

          owner = Model::Person.first :email => command.owner_email
          if owner.nil?
            owner = Model::Person.create :email => command.owner_email
            new_users << owner
          end
          fields.delete :owner_email
          fields[:owner] = owner

          fields[:collaborators] = []
          command.collaborator_emails.each do |email|
            collaborator = Model::Person.first :email => email
            if collaborator.nil?
              collaborator = Model::Person.create :email => email
              new_users << collaborator
            end
            fields[:collaborators] << collaborator
          end
          fields.delete :collaborator_emails

          todo_template = Model::TodoTemplate.create(fields)

          WQ::TaskResult.create_success_result command, {
            :new_users => new_users.map { |u| Model.model_to_task_result_hash u },
            :todo_template => Model.model_to_task_result_hash(todo_template)
          }
        end
      end
    end
  end
end

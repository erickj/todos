require 'set'
require 'workqueue/task'
require 'todo/mail'
require 'todo/model'
require 'todo/view'

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
        def process_command_internal(create_todo_command)
          fields = create_todo_command.to_h

          new_users = []

          owner = Model::Person.first :email => create_todo_command.owner_email
          if owner.nil?
            owner = Model::Person.create :email => create_todo_command.owner_email
            new_users << owner
          end
          fields.delete :owner_email
          fields[:owner] = owner

          fields[:collaborators] = []
          create_todo_command.collaborator_emails.each do |email|
            collaborator = Model::Person.first :email => email
            if collaborator.nil?
              collaborator = Model::Person.create :email => email
              new_users << collaborator
            end
            fields[:collaborators] << collaborator
          end
          fields.delete :collaborator_emails

          todo_template = Model::TodoTemplate.create(fields)

          WQ::TaskResult.create_success_result create_todo_command, {
            :new_users => new_users.map { |u| Model.model_to_task_result_hash u },
            :todo_template => Model.model_to_task_result_hash(todo_template)
          }
        end
      end

      class ResultProcessor
        include Todo::Command::Processor
        include Todo::Mail::Emailer
        include Todo::View::Renderer
        include Todo::View::Helper::Base

        view_layout :email

        processes WQ::Tasks.result_type TaskType::CREATE_TODO

        def subject_for(todo_result, todo_template)
          'Todo: [%s]' % todo_template.title
        end

        def process_command_internal(create_todo_result)
          task_result = create_todo_result.result
          todo_template = Model.task_result_hash_to_model task_result[:todo_template]
          new_users = task_result[:new_users].to_set.to_a.map do |u|
            Model.task_result_hash_to_model u
          end

          subject = subject_for(create_todo_result, todo_template)
          locals = {
            :todo_template => todo_template,
            :new_users => new_users,
            :role => :owner
          }
          email_builder
            .subject(subject)
            .reply_to(reply_to_slug todo_template.slug)
            .to(todo_template.owner)
            .body_txt(render :todo_create, :txt, locals)
            .body_html(render :todo_create, :html, locals)
            .send

          if todo_template.owner != todo_template.creator
            locals[:role] = :creator
            email_builder
              .subject(subject)
              .reply_to(reply_to_slug todo_template.slug)
              .to(todo_template.creator)
              .body_txt(render :todo_create, :txt, locals)
              .body_html(render :todo_create, :html, locals)
              .send
          end

          todo_template.collaborators.each do |collaborator|
            locals[:role] = :collaborator
            email_builder
              .subject(subject)
              .reply_to(reply_to_slug todo_template.slug)
              .to(collaborator)
              .body_txt(render :todo_create, :txt, locals)
              .body_html(render :todo_create, :html, locals)
              .send
          end

          WQ::TaskResult.create_success_result create_todo_result
        end
      end
    end
  end
end

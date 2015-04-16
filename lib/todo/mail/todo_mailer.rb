require 'mandrill'
require 'workqueue'
require 'logging'
require 'todo/command'

module Todo
  module Mail
    class TodoMailer
      include WQ::RedisConsumer
      include WQ::Subscriber
      include Logging

      COMMAND_SOURCE = Todo::Command::CommandSource.new

      class << self
        def workqueue_handlers
          [ COMMAND_SOURCE ]
        end
      end

      def initialize
        raise 'environment var MANDRILL_APIKEY not set for mandrill gem' unless ENV['MANDRILL_APIKEY']
      end

      def redis=(redis)
        @redis = redis
        self.pubsub_redis = redis

        do_subscribe
      end

      private
      def do_subscribe
        subscribe WQ::TASK_RESULT_CHANNEL, &method(:handle_pubsub_message)
      end

      def handle_pubsub_message(message)
        task_result = WQ::TaskSerializer.instance.deserialize(message)
        log.debug { 'received task type: %s' % task_result.task_type }

        case task_result.original_task.task_type
        when Command::TaskType::CREATE_TODO
          handle_create_todo_result(task_result)
        end
      end

      def handle_create_todo_result(task_result)
        COMMAND_SOURCE << task_result
      end
    end
  end
end

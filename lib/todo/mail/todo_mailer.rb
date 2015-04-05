require 'mandrill'
require 'workqueue'
require 'logging'
require 'todo/command'
require 'todo/model'

module Todo
  module Mail
    class TodoMailer
      include WQ::RedisConsumer
      include WQ::Subscriber
      include Logging

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

        case task_result.original_task_type
        when Command::TaskType::CREATE_TODO
          handle_create_todo_result(task_result)
        end
      end

      def handle_create_todo_result(task_result)
        log.info 'sending mail for created todo result: %s' % task_result.original_task_uuid
        todo_tpl = Model::TodoTemplate.by_uuid! task_result.result_key
        log.debug { todo_tpl }
        send_mail todo_tpl
      end

      def send_mail(todo_tpl)
        m = Mandrill::API.new
        message = {
          :subject=> "Re: %s" % todo_tpl.title,
          :from_name=> "domail",
          :text=>"Saved your todo:\n\n%s" % todo_tpl.description,
          :to=>[
            {
              :email=> ENV['OVERRIDE_EMAIL_RECIPIENT'],
              :name=> "Recipient1"
            }
          ],
#          :html=>"<html><h1>Hi <strong>message</strong>, how are you?</h1></html>",
          :from_email=>ENV['FROM_EMAIL']
        }
        m.messages.send message
      end
    end
  end
end

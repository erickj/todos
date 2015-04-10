require 'mandrill'
require 'workqueue'
require 'logging'
require 'todo/command'
require 'todo/model'
require 'todo/view/mailer_view'

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
        owner = todo_tpl.owner

        view = View::MailerView.new Command::TaskType::CREATE_TODO, todo_tpl, owner

        send_mail owner.email, todo_tpl.title, view
      end

      def send_mail(to, subject, view)
        m = Mandrill::API.new
        message = {
          :subject => "Re: %s" % subject,
          :from_name => "Do Til Done",
          :text => view.generate_txt,
          :to => [
            {
              :email=> ENV['OVERRIDE_EMAIL_RECIPIENT'] || to,
              :name=> "Recipient1"
            }
          ],
          :html => view.generate_html,
          :from_email => ENV['FROM_EMAIL']
        }
        m.messages.send message
      end
    end
  end
end

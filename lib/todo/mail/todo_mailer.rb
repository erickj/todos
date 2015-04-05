require 'workqueue'
require 'logging'

module Todo
  module Mail
    class TodoMailer
      include WQ::RedisConsumer
      include WQ::Subscriber
      include Logging

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
        log.info 'sending mail for result: %s' % task_result.original_task_uuid
      end
    end
  end
end

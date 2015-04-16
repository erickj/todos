module Todo
  module View
    module Helper
      module MessagesHelper
        def get_message(keys, *replacements)
          message_hash = Todo::View::MESSAGES

          msg = keys.reduce(message_hash) do |memo, key|
            raise 'missing message key %s' % keys.join(':') unless memo.key? key
            memo[key]
          end
          msg.nil? ? '' : msg % replacements
        end
      end
    end
  end
end

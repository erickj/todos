require 'dm-core'
require 'dm-serializer'
require 'dm-timestamps'
require 'dm-types'
require 'dm-validations'

require 'todo/model/person'
require 'todo/model/recurrence_rule'
require 'todo/model/template_attachment'
require 'todo/model/collaborator_assignment'
require 'todo/model/todo_template'

module Todo
  module Model

    class << self
      def model_to_task_result_hash(model)
          raise 'model must respond to #uuid' unless model.respond_to? :uuid
          raise 'model.class must respond to #by_uuid' unless model.class.respond_to? :by_uuid

          {
            :uuid => model.uuid.to_s,
            :class => model.class
          }
      end

      def task_result_hash_to_model(result)
        raise 'missing class' unless result[:class] && result[:class].respond_to?(:by_uuid)
        raise 'invalid uuid' unless result[:uuid] && UUIDTools::UUID.parse(result[:uuid])

        result[:class].by_uuid result[:uuid]
      end
    end
  end
end

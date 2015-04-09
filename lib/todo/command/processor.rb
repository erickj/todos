module Todo
  module Command
    module Processor

      def self.included(base)
        base.extend ClassMethods
      end

      # Called by Todo::Command::CommandSink to get a processor for a task type.
      def self.processor_for(task)
        ClassMethods.processor_for(task.task_type)
      end

      def process_command(command)
        unless self.class.allowed_command_types.any? { |type| command =~ type }
          raise ArgumentError, 'can not process command of type %s' % command.task_type
        end
        model = process_command_internal(command)
        result_key = model.uuid.to_s rescue nil

        WQ::TaskResult.create_from_task(command, :success, result_key)
      end

      protected
      def process_command_internal(command)
        nil
      end

      module ClassMethods

        attr_reader :allowed_command_types

        @@processor_registry = {}

        # Registers the processor to be responsible for processing the given
        # types. An instance of this class will be returned on calls to
        # Todo::Command::Processor.processor_for any of the given types.
        def processes(*types)
          types.each do |type|
            raise 'processor already registered for type %s'%type if @@processor_registry[type]
            @@processor_registry[type] = self
          end

          @allowed_command_types ||= []
          @allowed_command_types.concat types
        end

        private
        def self.processor_for(type)
          processor_klass = @@processor_registry[type]
          raise 'no processor registered for command type: %s' % type if processor_klass.nil?

          processor_klass.new
        end
      end
    end
  end
end

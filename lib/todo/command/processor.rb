module Todo
  module Command
    module Processor

      def self.included(base)
        base.extend ClassMethods
      end

      def process_command(command)
        unless self.class.allowed_command_types.any? { |type| command =~ type }
          raise ArgumentError, 'can not process command of type %s' % command.task_type
        end
        process_command_internal(command)
      end

      protected
      def process_command_internal(command)
        raise NotImplementedError
      end

      module ClassMethods

        attr_reader :allowed_command_types

        def processes(*types)
          @allowed_command_types ||= []
          @allowed_command_types.concat types
        end
      end

    end
  end
end

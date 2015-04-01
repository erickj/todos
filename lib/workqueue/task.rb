require 'util/object_util'

module WorkQueue

  class TaskValidationError < StandardError
    def initialize(field_errors = {})
      @field_errors = field_errors
      super 'Invalid values for fields: %s'%@field_errors.map { |pair| pair[0] }.join(',')
    end

    def error_for_field(name)
      @field_errors[name]
    end
    alias :[] :error_for_field
  end

  module TaskMixin

    def self.included(base)
      base.extend ClassMethods
    end

    attr_writer :task_type

    def task_type
      @task_type || self.class.task_type
    end

    def is_task?
      true
    end

    def ==(other)
      return false unless other.kind_of?(TaskMixin)
      Util::ObjectUtil.deep_equality_compare(self, other)
    end
    alias :eql? :==

    def =~(value)
      if value.is_a? Symbol
        return task_type == value
      end
      self == value
    end

    attr_writer :field_values
    attr_writer :errors

    def error(name)
      errors ||= {}
      errors[name]
    end

    def method_missing(name, *args)
      return field_value(name) if has_field?(name)
      super(name, *args)
    end

    # Returns a hash representing all the field values
    def to_h
      hash = {}
      self.class.field_definitions.each do |k, v|
        hash[k] = field_value k
      end
      hash
    end

    private
    def field_value(name)
      @field_values[name] || self.class.field_definitions[name].get_default
    end

    def has_field?(field)
      self.class.has_field? field
    end

    module ClassMethods

      attr_reader :field_definitions

      def task_type(type=nil)
        @task_type ||= type
      end

      def field(name)
        @field_definitions ||= {}
        raise ArgumentError, 'field %s already defined'%(name) if has_field? name

        @field_definitions[name] = FieldDefinition.new
      end

      def has_field?(name)
        @field_definitions.has_key? name
      end

      def build(field_values)
        task = self.allocate

        validation_errors = {}
        @field_definitions.each do |name, defn|
          is_valid, field_validation_errors = @field_definitions[name].check_is_valid(name, field_values[name])
          unless is_valid
            validation_errors[name] = field_validation_errors
          end
        end

        unless validation_errors.empty?
          raise TaskValidationError, validation_errors
        end

        task.field_values = field_values
        task
      end
    end

    class FieldDefinition

      def default(v)
        @default = v
        self
      end

      def required
        validate { |v| raise 'missing required value' if v.nil? }
        self
      end

      def type(klass)
        validate { |v| raise 'expected type %s'%klass unless v.is_a? klass }
        self
      end

      def validate(validator_proc=nil, &block)
        @validators ||= []
        @validators << validator_proc unless validator_proc.nil?
        @validators << block if block_given?
        self
      end

      def get_default
        @default
      end

      def check_is_valid(name, value)
        return [true, []] if @validators.nil? || @validators.empty?

        validation_errors = []
        @validators.each do |validator|
          begin
            validator.call(value)
          rescue StandardError
            validation_errors << $!.message
          end
        end

        return [validation_errors.empty?, validation_errors]
      end
    end

  end

  class Task
    include TaskMixin

    task_type :default

    def initialize(type=nil)
      self.task_type = type
    end
  end
end

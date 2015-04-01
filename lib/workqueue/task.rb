require 'util/object_util'

module WorkQueue
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

    module ClassMethods

      def task_type(type=nil)
        @task_type ||= type
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

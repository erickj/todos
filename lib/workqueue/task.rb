require 'util/object_util'

module WorkQueue
  module TaskMixin

    attr_reader :task_type

    def is_task?
      true
    end

    def ==(other)
      return false unless other.is_a?(Task)
      Util::ObjectUtil.deep_equality_compare(self, other)
    end
    alias :eql? :==

    def =~(value)
      if value.is_a? Symbol
        return task_type == value
      end
      self == value
    end
  end

  class Task
    include TaskMixin

    def initialize(task_type = :default)
      @task_type = task_type
    end
  end
end

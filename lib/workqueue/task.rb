require 'util/object_util'

module WorkQueue
  module TaskMixin

    attr_accessor :task_type

    def is_task?
      true
    end

    def ==(other)
      return false unless other.is_a?(Task)
      Util::ObjectUtil.deep_equality_compare(self, other)
    end
    alias :eql? :==
  end

  class Task
    include TaskMixin

    def initialize(task_type = :default)
      @task_type = task_type
    end
  end
end

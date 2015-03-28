require 'util/object_util'

module WorkQueue
  module TaskMixin

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
  end
end

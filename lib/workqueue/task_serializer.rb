require 'singleton'

module WorkQueue

  class TaskSerializer

    # Override
    def self.instance
      MarshalingTaskSerializer.send :new
    end

    def serialize(task)
      serialize_internal(task)
    end

    def deserialize(str)
      raise ArgumentError, "expected type string" unless str.is_a?(String)
      deserialize_internal(str)
    end

    protected
    def serialize_internal(task)
      raise NotImplementedError
    end

    def deserialize_internal(str)
      raise NotImplementedError
    end
  end

  class MarshalingTaskSerializer < TaskSerializer

    private_class_method :new

    def serialize_internal(task)
      Marshal.dump(task)
    end

    def deserialize_internal(str)
      Marshal.restore(str)
    end
  end
end

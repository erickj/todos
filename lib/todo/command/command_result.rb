module Todo
  module Command
    class CommandResult
      def initialize(result, task)
        @result = result
        @task = task
      end

      attr_reader :uuid, :task
    end
  end
end

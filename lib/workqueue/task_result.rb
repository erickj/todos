module WorkQueue
  class TaskResult
    include WorkQueue::TaskMixin

    task_type :task_result

    field(:original_task)
      .required
      .type TaskMixin

    field(:result_status)
      .enum(:success, :error)
      .default :success

    field(:result)
      .default(nil)

    field(:error)
      .default(nil)
      .type String

    def is_success?
      self.result_status == :success
    end

    def self.create_success_result(original_task, result={})
      TaskResult.build({
        :original_task => original_task,
        :result_status => :success,
        :result => result
      }, original_task.result_type)
    end

    def self.create_error_result(original_task, error='')
      TaskResult.build({
        :original_task => original_task,
        :result_status => :error,
        :error => error
      }, original_task.result_type)
    end
  end
end

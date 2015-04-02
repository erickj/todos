module WorkQueue
  class TaskResult
    include WorkQueue::TaskMixin

    task_type :task_result

    field(:original_task_type)
      .required
      .type Symbol

    field(:original_task_uuid)
      .required
      .validate { |uuid| raise 'value is not a UUID' unless !!UUIDTools::UUID.parse(uuid) }

    field(:result)
      .enum(:success, :fail)
      .default :success

    field(:result_key)
      .type String

    def is_success?
      self.result == :success
    end

    def self.create_from_task(task, result=success, result_key=nil)
      TaskResult.build({
        :original_task_uuid => task.uuid,
        :original_task_type => task.task_type,
        :result => result,
        :result_key => result_key
      })
    end
  end
end

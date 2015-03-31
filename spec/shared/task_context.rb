require 'workqueue'

RSpec.shared_context 'a task' do

  let(:task_serializer) { WQ::TaskSerializer.instance }

  def serialize_task(todo)
    task_serializer.serialize(todo)
  end

  def deserialize_task(serialized_todo)
    task_serializer.deserialize(serialized_todo)
  end
end

require 'workqueue'

RSpec.describe WQ::TaskMixin, :wq do

  let(:task) { WQ::Task.new }

  it 'is a task' do
    expect(task.is_task?).to be
  end

  it 'is of default type' do
    expect(task.task_type).to be :default
  end
end

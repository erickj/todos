require 'workqueue'

RSpec.describe WQ::TaskMixin, :wq do

  let(:task) { WQ::Task.new }

  it 'is a task' do
    expect(task.is_task?).to be
  end

  it 'is of default type' do
    expect(task.task_type).to be :default
  end

  it 'is =~ equal to its type' do
    foo_task = WQ::Task.new(:foo)
    expect(foo_task =~ :foo).to be
  end

  it 'is =~ equal to itself' do
    foo_task = WQ::Task.new(:foo)
    expect(foo_task =~ foo_task).to be
  end
end

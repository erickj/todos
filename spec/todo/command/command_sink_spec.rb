require 'workqueue/task'
require 'todo/command'
require 'shared/task_context'
require 'shared/dummy_redis_context'

RSpec.describe Todo::Command::CommandSink, :command do

  include_context 'a dummy redis'
  include_context 'a task'

  let(:create_task) do
    Todo::Command::CreateTodo::Command.build({
                                               :owner_email => 'e@j.com',
                                               :title => 'a title',
                                               :description => 'a description'
                                             })
  end

  let(:noop_task) { WQ::Task.new(Todo::Command::TaskType::NOOP_TODO) }

  before(:each) do
    subject.redis = dummy_redis
  end

  context 'events' do
    it 'emits a time for :process_command_begin and :process_command_end' do
      begin_time = nil
      end_time = nil
      subject.on(:process_command_begin) { |time| begin_time = time }
      subject.on(:process_command_end) { |time| end_time = time }

      dummy_redis.rpush(Todo::Command::QUEUE_NAME, serialize_task(noop_task))

      before_tick_time = Time.now
      subject.handle_tick

      expect(begin_time).to be > before_tick_time
      expect(begin_time).to be < end_time
      expect(end_time).to be < Time.now
    end
  end
end
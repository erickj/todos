require 'workqueue'
require 'shared/wq_handler_examples'

RSpec.describe WQ::TaskSink, :wq do

  # set subject for shared examples
  subject { WQ::TaskSink.new :queue_name }

  it_behaves_like 'a wq::handler'

  let(:replies) do
    hash_of_lists = {}
    {
      :rpush  => lambda do |key, val|
        list = hash_of_lists[key] ||= []
        list.push(val)
        list.size
      end,
      :lpop => lambda do |key|
        list = hash_of_lists[key] ||= []
        list.shift
      end
    }
  end

  context 'handle_tick' do

    let(:serializer) { WQ::TaskSerializer.instance }
    let(:task) { WQ::Task.new }

    it 'returns a failed deferred if queue is empty' do
      em_hiredis_mock(replies) do |redis|
        subject.redis = redis

        failed_result = subject.handle_tick
        errback_called = false
        failed_result.errback { errback_called = true }
        expect(errback_called). to be

        expect(redis.call_count).to be(1)
      end
    end

    it 'returns a succeeded deferred if queue returns a member' do
      em_hiredis_mock(replies) do |redis|
        serialized_task = serializer.serialize(task)
        redis.rpush(:queue_name, serialized_task) do |rpush_size|
          expect(rpush_size).to be 1
        end

        subject.redis = redis

        success_result = subject.handle_tick
        callback_called = false
        success_result.callback { callback_called = true }
        expect(callback_called). to be

        expect(redis.call_count).to be(2) # +1 for the rpush above
      end
    end

    it 'processes a deserialized task in the task handler' do
      em_hiredis_mock(replies) do |redis|
        serialized_task = serializer.serialize(task)
        redis.rpush(:queue_name, serialized_task) do |rpush_size|
          expect(rpush_size).to be 1
        end

        task_handler_called = false
        sink = WQ::TaskSink.new(:queue_name) do |handled_task|
          expect(handled_task).to eql task
          task_handler_called = true
        end
        sink.redis = redis
        sink.handle_tick

        expect(task_handler_called).to be
      end
    end
  end
end

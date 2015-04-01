require 'workqueue'
require 'shared/wq_handler_examples'

RSpec.describe WQ::TaskSource, :wq do

  # set subject for shared examples
  subject { WQ::TaskSource.new :queue_name }

  it_behaves_like 'a wq::handler'

  let(:replies) do
    hash_of_lists = {}
    {
      :rpush  => lambda do |key, val|
        list = hash_of_lists[key] ||= []
        list.push(val)
        list.size
      end
    }
  end

  it 'raises an ArgumentError if for non-tasks' do
    expect { subject.queue_task {} }.to raise_error ArgumentError
  end

  it 'queues a task for pushing onto a queue' do
    expect(subject).to be_empty
    subject.queue_task WQ::Task.new
    expect(subject).to_not be_empty
  end

  it 'aliases +queue_task+ with <<' do
    expect(subject).to be_empty
    subject << WQ::Task.new
    expect(subject).to_not be_empty
  end

  context 'handle_tick' do

    let(:task) { WQ::Task.new }

    it 'returns failed deferrable if there are no pending tasks' do
      em_hiredis_mock(replies) do |redis|
        subject.redis = redis

        failed_result = subject.handle_tick
        errback_called = false
        failed_result.errback { errback_called = true }
        expect(errback_called). to be
        expect(redis.call_count).to be(0)
      end
    end

    it 'returns succeeded deferrable if there are pending tasks' do
      em_hiredis_mock(replies) do |redis|
        subject.redis = redis
        subject.queue_task(task)

        success_result = subject.handle_tick
        callback_called = false
        success_result.callback { callback_called = true }
        expect(callback_called). to be
      end
    end

    it 'pushes queued tasks onto redis list named :queue_name' do
      em_hiredis_mock(replies) do |redis|
        subject.redis = redis
        subject.queue_task(task)

        subject.handle_tick

        expect(redis.call_count).to be(1)
        expect(redis.last[:args]).to be == [
                                       :queue_name,
                                       WQ::TaskSerializer.instance.serialize(task)
                                     ]
      end
    end

    it 'pushes multiple tasks' do
      em_hiredis_mock(replies) do |redis|
        subject.redis = redis
        subject.queue_task(WQ::Task.new)
        subject.queue_task(WQ::Task.new)
        subject.queue_task(WQ::Task.new)

        subject.handle_tick

        expect(redis.call_count).to be(3)
      end
    end

    it 'empties its queue after pushing all tasks' do
      em_hiredis_mock(replies) do |redis|
        subject.redis = redis
        subject.queue_task(task)
        subject.handle_tick
        expect(redis.call_count).to be(1)

        failed_result = subject.handle_tick
        errback_called = false
        failed_result.errback { errback_called = true }
        expect(errback_called). to be

        expect(redis.call_count).to be(1)
      end
    end

  end
end

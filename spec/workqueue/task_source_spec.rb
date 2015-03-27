require 'workqueue'

RSpec.describe WQ::TaskSource, :wq do
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

  it 'queues a task for pushing onto a queue' do
    source = WQ::TaskSource.new(:queue_name, WQ::TaskSerializer.instance)
    source.queue_task(WQ::Task.new)
  end

  context 'handle_tick' do

    let(:serializer) { WQ::TaskSerializer.instance }
    let(:task) { WQ::Task.new }

    it 'returns false if there are no pending tasks' do
      em_hiredis_mock(replies) do |redis|
        source = WQ::TaskSource.new(:queue_name, serializer)

        expect(source.handle_tick(redis)).to be(false)
        expect(redis.call_count).to be(0)
      end
    end

    it 'pushes queued tasks onto redis list named :queue_name' do
      em_hiredis_mock(replies) do |redis|
        source = WQ::TaskSource.new(:queue_name, serializer)
        source.queue_task(task)

        expect(source.handle_tick(redis)).to be
        expect(redis.call_count).to be(1)
        expect(redis.last[:args]).to be == [ :queue_name, serializer.serialize(task) ]
      end
    end

    it 'pushes multiple tasks' do
      em_hiredis_mock(replies) do |redis|
        source = WQ::TaskSource.new(:queue_name, serializer)
        source.queue_task(WQ::Task.new)
        source.queue_task(WQ::Task.new)
        source.queue_task(WQ::Task.new)

        expect(source.handle_tick(redis)).to be
        expect(redis.call_count).to be(3)
      end
    end

    it 'empties its queue after pushing all tasks' do
      em_hiredis_mock(replies) do |redis|
        source = WQ::TaskSource.new(:queue_name, serializer)
        source.queue_task(task)
        source.handle_tick(redis)
        expect(redis.call_count).to be(1)

        expect(source.handle_tick(redis)).to be(false)
        expect(redis.call_count).to be(1)
      end
    end
  end
end

require 'workqueue'

RSpec.shared_context 'a dummy redis' do

  let(:dummy_redis_replies) do
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

  let(:dummy_redis) { em_hiredis_mock(dummy_redis_replies) }

end

require 'workqueue'

RSpec.describe WQ::TaskSource, :wq do
  let(:replies) do
    {
      :rpush  => lambda { |key, val| 1 }
    }
  end

  it 'tests rspec mock' do
    em_hiredis_mock(replies) do |redis|
      redis.rpush(:key, :val) { |len| expect(len).to be(1) }
    end
  end

end

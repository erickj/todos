shared_examples 'a wq::publisher' do

  let(:published_messages) { [] }

  let!(:redis) do
    em_hiredis_mock({
      :publish => lambda { |channel, *args| published_messages.push([channel, args]) }
    })
  end

  context 'publisher' do

    it 'should allow assigning a redis instance' do
      expect do
        subject.pubsub_redis = redis
      end.to_not raise_error
    end

    it 'should raise an error when redis is not set' do
      expect do
        subject.publish :deadletter, "is anybody out there"
      end.to raise_error RuntimeError, /^redis instance not set/
    end

    it 'should publish messages to a channel' do
      subject.pubsub_redis = redis

      expect(published_messages).to be_empty

      subject.publish(:the_hotness_channel, "a very important message")

      expect(published_messages.size).to be 1
      expect(published_messages.first).to eql [ :the_hotness_channel, ["a very important message"]]
    end

  end

end

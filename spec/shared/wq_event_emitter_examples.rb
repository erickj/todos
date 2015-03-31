shared_examples 'a wq::event_emitter' do

  context 'event emitter' do

    it 'should emit events' do
      handler_called = false
      subject.on :event do
        handler_called = true
      end

      subject.emit :event
      expect(handler_called).to be
    end
  end

end

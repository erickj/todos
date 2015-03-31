require 'shared/wq_event_emitter_examples'
require 'shared/wq_publisher_examples'

RSpec.shared_examples 'a wq::handler' do

  it_behaves_like 'a wq::event_emitter'
  it_behaves_like 'a wq::publisher'

  let!(:redis) do
    em_hiredis_mock({ :lpop => lambda { |*_| nil } })
  end

  context 'events' do
    it 'emits a time for :handle_tick_begin and :handle_tick_end event' do
      begin_time = nil
      end_time = nil
      subject.on(:handle_tick_begin) { |time| begin_time = time }
      subject.on(:handle_tick_end) { |time| end_time = time }

      before_tick = Time.now
      subject.handle_tick(redis)

      expect(begin_time).to be > before_tick
      expect(begin_time).to be < end_time
      expect(end_time).to be < Time.now
    end
  end

end

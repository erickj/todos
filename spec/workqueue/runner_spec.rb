require 'workqueue'

RSpec.describe WQ::Runner, :wq do

  let!(:redis) { em_hiredis_mock }

  before(:each) do
    # Stub EM::Hiredis with local `redis`
    allow(EM::Hiredis).to receive(:connect) { redis }
  end

  context :setup_reactor_hooks do
    it 'validates handlers respond to +handle_tick+' do
      expect { WQ::Runner.new(StubHandler.new) }.to_not raise_error
      expect { WQ::Runner.new(Object.new) }.to raise_error ArgumentError
    end

    it 'raises an error if the EM reactor is not running' do
      runner = WQ::Runner.new
      expect { runner.setup_reactor_hooks }.to raise_error(RuntimeError)
    end

    it 'connects to redis' do
      expect(EM::Hiredis).to receive(:connect) { redis }

      runner = WQ::Runner.new
      em do
        expect { runner.setup_reactor_hooks }.to_not raise_error
        done
      end
    end

    it 'passes redis to handlers from the event loop' do
      handler = nil
      em do
        handler = StubHandler.new do |redis_from_em|
          expect(redis_from_em).to be(redis)
          done
        end
        runner = WQ::Runner.new(handler)
        runner.setup_reactor_hooks
      end

      expect(handler.call_count).to be 1
    end

    it 'always calls handlers that return true' do
      handler = nil
      em do
        handler = StubHandler.new do |*_|
          done if handler.call_count == 1
          true
        end
        runner = WQ::Runner.new(handler)
        runner.setup_reactor_hooks
      end

      expect(handler.call_count).to be 2
    end

    # TODO(erick): This test could easily lead to flakes
    it 'un/reschedules handlers that return false' do
      control_handler, handler = nil
      em do
        control_handler = StubHandler.new true
        handler = StubHandler.new do |*_|
          done if handler.call_count == 1
          control_handler.call_count == 2
        end

        # set_periodic_timer_interval to a small non-zero value
        runner = WQ::Runner.new(control_handler, handler).set_periodic_timer_interval(0.01)
        runner.setup_reactor_hooks
      end

      expect(handler.call_count).to be 1
      expect(control_handler.call_count).to be 2
    end
  end

  class StubHandler
    def initialize(handle_tick_return=true, &block)
      @handle_tick_return = !!handle_tick_return
      @handler = block || nil
      @call_count = 0
    end

    attr_reader :call_count

    def handle_tick(redis)
      @call_count += 1
      @handler.nil? ? @handle_tick_return : @handler.call(redis)
    end
  end
end

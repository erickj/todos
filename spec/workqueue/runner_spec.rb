require 'workqueue'

RSpec.describe WQ::Runner, :wq do

  EM_TIMEOUT = 1

  let!(:redis) { em_hiredis_mock }

  context :setup_reactor_hooks do
    it 'validates handlers respond to +handle_tick+' do
      expect { WQ::Runner.new(redis, StubHandler.new) }.to_not raise_error
      expect { WQ::Runner.new(redis, Object.new) }.to raise_error ArgumentError
    end

    it 'raises an error if the EM reactor is not running' do
      runner = WQ::Runner.new(redis)
      expect { runner.setup_reactor_hooks }.to raise_error(RuntimeError)
    end

    it 'passes redis to handlers from the event loop' do
      handler = nil
      em(EM_TIMEOUT) do
        handler = StubHandler.new do |redis_from_em|
          expect(redis_from_em).to be(redis)
          done
        end
        runner = WQ::Runner.new(redis, handler)
        runner.setup_reactor_hooks
      end

      expect(handler.call_count).to be 1
    end

    it 'always calls handlers that return true' do
      handler = nil
      em(EM_TIMEOUT) do
        handler = StubHandler.new do |*_|
          done if handler.call_count == 1
          true
        end
        runner = WQ::Runner.new(redis, handler)
        runner.setup_reactor_hooks
      end

      expect(handler.call_count).to be 2
    end

    # TODO(erick): This test could easily lead to flakes
    it 'un/reschedules handlers that return false' do
      control_handler, handler = nil
      em(EM_TIMEOUT) do
        control_handler = StubHandler.new true
        handler = StubHandler.new do |*_|
          done if handler.call_count == 1
          control_handler.call_count == 2
        end

        # set_periodic_timer_interval to a small non-zero value
        runner = WQ::Runner.new(redis, control_handler, handler).set_periodic_timer_interval(0.01)
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

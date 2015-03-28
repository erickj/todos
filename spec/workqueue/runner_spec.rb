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
        handler = StubHandler.new(false) do |redis_from_wq|
          expect(redis_from_wq).to be(redis)
          done
        end
        runner = WQ::Runner.new(redis, handler)
        runner.setup_reactor_hooks
      end

      expect(handler.call_count).to be 1
    end

    it 'reschedules succeeded handlers' do
      handler = nil
      em(EM_TIMEOUT) do
        handler = StubHandler.new(true) do |*_|
          done if handler.call_count == 1
        end
        runner = WQ::Runner.new(redis, handler)
        runner.setup_reactor_hooks
      end

      expect(handler.call_count).to be 2
    end

    it 'unschedules handlers that return false' do
      control_handler, handler_under_test = nil
      em(EM_TIMEOUT) do
        control_handler = StubHandler.new(true) do |*_|
          done if control_handler.call_count == 1
        end
        handler_under_test = StubHandler.new(false)

        runner = WQ::Runner.new(redis, control_handler, handler_under_test)
        runner.setup_reactor_hooks
      end

      expect(handler_under_test.call_count).to be 1
      expect(control_handler.call_count).to be 2
    end

    it 'reschedules failed handlers' do
      control_handler, handler_under_test = nil
      em(EM_TIMEOUT) do
        control_handler = StubHandler.new(true) do |*_|
          done if control_handler.call_count == 1
        end
        handler_under_test = StubHandler.new(false)

        runner = WQ::Runner.new(redis, control_handler, handler_under_test)
        runner.set_periodic_timer_interval(0)
        runner.setup_reactor_hooks
      end

      expect(handler_under_test.call_count).to be 2
      expect(control_handler.call_count).to be 2
    end
  end

  class StubHandler
    def initialize(should_succeed=true, &block)
      @deferred = EM::DefaultDeferrable.new
      should_succeed ? @deferred.succeed : @deferred.fail

      @handler = block || nil
      @call_count = 0
    end

    attr_reader :call_count

    def handle_tick(redis)
      @call_count += 1
      @handler.call(redis) unless @handler.nil?
      @deferred
    end
  end
end

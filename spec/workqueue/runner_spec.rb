require 'workqueue'

RSpec.describe WQ::Runner, :wq do

  EM_TIMEOUT = 0.5

  context :setup_reactor_hooks do
    it 'validates handlers respond to +handle_tick+' do
      expect { WQ::Runner.new(StubHandler.new) }.to_not raise_error
      expect { WQ::Runner.new(Object.new) }.to raise_error ArgumentError
    end

    it 'raises an error if the EM reactor is not running' do
      runner = WQ::Runner.new
      expect { runner.setup_reactor_hooks }.to raise_error(RuntimeError)
    end

    it 'should reschedule succeeded handlers' do
      handler = nil
      em(EM_TIMEOUT) do
        handler = StubHandler.new(true) do |*_|
          done if handler.call_count == 1
        end
        WQ::Runner.new(handler)
          .setup_reactor_hooks
      end

      expect(handler.call_count).to be 2
    end

    it 'should unschedules handlers with unkown failures' do
      control_handler, handler_under_test = nil
      em(EM_TIMEOUT) do
        control_handler = StubHandler.new(true) do |*_|
          done if control_handler.call_count == 1
        end
        handler_under_test = StubHandler.new(false, :unknown_error)

        WQ::Runner.new(control_handler, handler_under_test)
          .setup_reactor_hooks
      end

      expect(handler_under_test.call_count).to be 1
      expect(control_handler.call_count).to be 2
    end

    it 'should reschedule failed handlers with code :nodata' do
      control_handler, handler_under_test = nil
      em(EM_TIMEOUT) do
        control_handler = StubHandler.new(true) do |*_|
          done if control_handler.call_count == 1
        end
        handler_under_test = StubHandler.new(false, :nodata)

        WQ::Runner.new(control_handler, handler_under_test)
          .set_periodic_timer_interval(0)
          .setup_reactor_hooks
      end

      expect(handler_under_test.call_count).to be 2
      expect(control_handler.call_count).to be 2
    end

    it 'should not reschedule timed out handlers' do
      control_handler, handler_that_times_out = nil
      em(EM_TIMEOUT) do
        control_handler = StubHandler.new(true) do |*_|
          done if control_handler.call_count == 2
        end
        handler_that_times_out = StubHandler.new(nil)

        WQ::Runner.new(control_handler, handler_that_times_out)
          .set_periodic_timer_interval(0.01)
          .set_timeout(0)
          .setup_reactor_hooks
      end

      expect(handler_that_times_out.call_count).to be 1
      expect(control_handler.call_count).to be 2

      errback_called = false
      handler_that_times_out.deferred.errback do |result|
        expect(result).to be :timeout
        errback_called = true
      end
      expect(errback_called).to be
    end
  end

  class StubHandler

    # @param [boolean|nil] should_succeed, nil indicates timeout
    def initialize(should_succeed=true, failure_code = nil, &block)
      @deferred = EM::DefaultDeferrable.new

      unless should_succeed.nil?
        should_succeed ? @deferred.succeed : @deferred.fail(failure_code)
      end

      @handler = block || nil
      @call_count = 0
    end

    attr_reader :call_count
    attr_reader :deferred

    def handle_tick
      @call_count += 1
      @handler.call if @handler
      @deferred
    end
  end
end

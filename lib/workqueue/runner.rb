require 'eventmachine'

module WorkQueue
  class Runner

    def initialize(redis, *handlers)
      handlers.each do |handler|
        raise ArgumentError, "must respont to handle_tick" unless handler.respond_to? :handle_tick
      end

      @redis = redis
      @handlers = handlers

      @unscheduled_handlers = []
      @periodic_timer_interval = 3 # seconds
    end

    def set_periodic_timer_interval(interval)
      @periodic_timer_interval = interval
      self
    end

    def setup_reactor_hooks
      raise "EM reactor not running, did you call EM.run?" unless EM.reactor_running?

      @handlers.each do |handler|
        schedule_handler(handler, true)
      end

      EM.add_periodic_timer(@periodic_timer_interval) do
        reschedule_unscheduled_handlers
      end
    end

    private
    def schedule_handler(handler, reschedule)
      callback = EM.Callback do
        reschedule_immediate = handler.handle_tick(@redis)
        next unless reschedule

        if reschedule_immediate
          EM.next_tick(callback)
        else
          @unscheduled_handlers << handler
        end
      end

      EM.next_tick(callback)
    end

    def reschedule_unscheduled_handlers
      tmp = @unscheduled_handlers
      @unscheduled_handlers = []

      tmp.each do |handler|
        schedule_handler(handler, true)
      end
    end
  end
end

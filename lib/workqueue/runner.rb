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
        schedule_handler(handler)
      end

      EM.add_periodic_timer(@periodic_timer_interval) do
        reschedule_unscheduled_handlers
      end
    end

    private
    # Schedules +handler+ to run on the reactor loop. The handler
    # should return a deferred from +handle_tick+. Once the deferred
    # succeeds, +handler+ will be immediately rescheduled on the next
    # tick of the loop. If this deferred fails, +handler+ will be
    # paused for +@periodic_timer_interval+ seconds+ before being
    # rescheduled.
    def schedule_handler(handler)
      scheduled_handler_cb = EM.Callback do
        handler.handle_tick(@redis)
          .callback{ schedule_handler(handler) }
          .errback{ @unscheduled_handlers << handler }
      end

      EM.next_tick(scheduled_handler_cb)
    end

    def reschedule_unscheduled_handlers
      tmp = @unscheduled_handlers
      @unscheduled_handlers = []

      tmp.each do |handler|
        schedule_handler(handler)
      end
    end
  end
end

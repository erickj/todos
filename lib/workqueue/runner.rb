require 'eventmachine'

module WorkQueue

  # Schedules calls to +handlers#handle_tick+ methods via the
  # EventMachine run loop
  class Runner

    DEFAULT_INTERVAL = 3 # seconds
    DEFERRED_TIMEOUT = 3 # seconds

    def initialize(redis, *handlers)
      handlers.each do |handler|
        raise ArgumentError, "must respont to handle_tick" unless handler.respond_to? :handle_tick
      end

      @redis = redis
      @handlers = handlers

      @unscheduled_handlers = []
      @timedout_handlers = []
      @periodic_timer_interval = DEFAULT_INTERVAL
      @deferred_timeout = DEFERRED_TIMEOUT
    end

    def set_periodic_timer_interval(interval)
      @periodic_timer_interval = interval
      self
    end

    def set_timeout(timeout)
      @deferred_timeout = timeout
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
    # rescheduled. A timeout is added to each deferred so that we can
    # clear out dead handlers. Once timed out a handler is placed into
    # the @timedout_handlers array and not rescheduled.
    def schedule_handler(handler)
      scheduled_handler_cb = EM.Callback do
        handler.handle_tick(@redis)
          .timeout(@deferred_timeout, :timeout)
          .callback { schedule_handler(handler) }
          .errback do |*args|
          if args[0] == :timeout
            @timedout_handlers << handler
          else
            @unscheduled_handlers << handler
          end
        end
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

require 'eventmachine'

module WorkQueue

  # Schedules calls to +handlers#handle_tick+ methods via the
  # EventMachine run loop
  class Runner

    include Logging

    # Interval between rescheduling unscheduled handlers
    DEFAULT_INTERVAL = 0.1 # seconds

    # Timeout until +handle_tick+ deferred raises a timeout errors
    DEFERRED_TIMEOUT = 3 # seconds

    def initialize(*handlers)
      handlers.each do |handler|
        unless handler.respond_to? :handle_tick
          raise ArgumentError, "%s must respont to handle_tick"%handler
        end
      end

      @handlers = handlers

      @unscheduled_handlers = []
      @banned_handlers = []
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
    # the @banned_handlers array and not rescheduled.
    def schedule_handler(handler)
      scheduled_handler_cb = EM.Callback do
        begin
          deferred = handler.handle_tick
            .timeout(@deferred_timeout, :timeout)
            .callback { schedule_handler(handler) }
            .errback { |*args| handle_error_on_deferred(handler, deferred, *args) }
          log.debug 'handle_tick returned defered: %s/%s' % [handler, deferred]
        rescue
          log_error 'scheduled %s#handle_tick'%handler.class, $!
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

    def handle_error_on_deferred(handler, deferred, *args)
      reason = args[0]
      case reason
      when :nodata
        log.debug "handler +handle_tick+ had no data, temporarily unscheduling"
        @unscheduled_handlers << handler
      when :timeout
        log.error "%s/%s timed out, permanently unscheduling" % [handler, deferred]
        @banned_handlers << handler
      else
        log.error "handler +handle_tick+ errorred with unknown reason: '%s'; unscheduling permanently"%reason
        @banned_handlers << handler
      end
    end
  end
end

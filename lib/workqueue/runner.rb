require 'eventmachine'
require 'em-hiredis'

module Workqueue
  class Runner

    def initialize(task_sources, task_sinks)
      @handlers = [task_sources, task_sinks].flatten
      @redis = nil

      @unscheduled_handlers = []
    end

    def run
      EM.run do
        @redis = EM::Hiredis.connect

        @handlers.each do |handler|
          schedule_handler(handler, true)
        end

        EM.add_periodic_timer(3) do
          reschedule_unscheduled_handlers
        end
      end
    end

    private
    def schedule_handler(handler, reschedule)
      raise ArgumentError, "must respont to handle_tick" unless handler.responds_to? :handle_tick

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

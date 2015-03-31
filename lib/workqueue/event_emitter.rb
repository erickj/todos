# scoped from EM::Hirdes::EventEmitter
# https://github.com/mloughran/em-hiredis/blob/master/lib/em-hiredis/event_emitter.rb
module WorkQueue
  module EventEmitter
    def on(event, &listener)
      _listeners[event] << listener
    end

    def emit(event, *args)
      _listeners[event].each { |l| l.call(*args) }
    end

    def remove_listener(event, &listener)
      _listeners[event].delete(listener)
    end

    def remove_all_listeners(event)
      _listeners.delete(event)
    end

    def listeners(event)
      _listeners[event]
    end

    private

    def _listeners
      @_listeners ||= Hash.new { |h,k| h[k] = [] }
    end
  end
end

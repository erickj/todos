unless $LOAD_PATH.include? './lib'
  $LOAD_PATH.unshift './lib'
end

require 'data_mapper'
require 'workqueue'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3:///' + ENV['RUN_DIR'] + '/todo.db');

module Todo
  class App

    def self.start &block
      self.new.start(&block)
    end

    def config &block
      yield self
      self
    end

    def start &config_block
      if block_given?
        config(&config_block)
      end

      Thread.new do
        unless wq_handlers.nil? || wq_handlers.empty?
          EM.run do
            redis = EM::Hiredis.connect(@redis_url)
            WQ::Runner.new(redis, @wq_handlers).setup_reactor_hooks
          end
        end
      end
    end

    attr_reader :wq_handler

    def web_root=(root)
      raise ArgumentError, "invalid web-root, must be a valid path" unless root.match(/\/$/)
      @web_root = root
    end

    def web_root
      @web_root || ""
    end

    def redis_url(url)
      @redis_url = url
      self
    end

    def add_wq_event_handlers(*handlers)
      @wq_handlers ||= []
      @wq_handlers.concat(handlers)
      self
    end

  end
end

#DataMapper.auto_migrate!
DataMapper
  .finalize
  .auto_upgrade!

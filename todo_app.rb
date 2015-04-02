unless $LOAD_PATH.include? './lib'
  $LOAD_PATH.unshift './lib'
end

require 'data_mapper'
require 'workqueue'
require 'todo/model'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3:///' + ENV['RUN_DIR'] + '/todo.db');


#DataMapper.auto_migrate!
DataMapper
  .finalize
  .auto_upgrade!

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

      puts "start eventmachine"
      redis = nil
      begin
        EM.run do
          redis = EM::Hiredis.connect(@redis_url)
          wq_handlers.each do |handler|
            handler.redis = redis
          end
          WQ::Runner.new(*wq_handlers).setup_reactor_hooks

          unless @app_mappings.nil?
            mappings = @app_mappings
            web_dispatch = Rack::Builder.app do
              mappings.each do |route, app|
                map route do run app end
              end
            end
            Rack::Server.start({
                                 :app => web_dispatch,
                                 :server => 'thin',
                                 :Port => 8000,
                                 :signals => false
                               })
          end

          puts "EM running"
        end
      rescue
        puts 'Error in EM.run loop:'
        puts $!, $@, $!.backtrace.join("\n\t")
      ensure
        redis.close_connection unless redis.nil?
      end
    end

    attr_reader :wq_handlers

    def map(route, app)
      @app_mappings ||= {}
      @app_mappings[route] = app
    end

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

    def add_wq_event_handler(handler)
      @wq_handlers ||= []
      @wq_handlers << handler
      self
    end

    def add_wq_event_handlers(handlers)
      @wq_handlers ||= []
      @wq_handlers.concat(handlers)
      self
    end

  end
end

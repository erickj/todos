unless $LOAD_PATH.include? './lib'
  $LOAD_PATH.unshift './lib'
end

require 'rack'
require 'rack/lobster'
require 'data_mapper'
require 'workqueue'
require 'todo/model'

module Todo
  class App

    DEFAULT_REDIS_URL = 'redis://localhost:6379/'
    DEFAULT_DB_URL = 'sqlite3:///' + ENV['RUN_DIR'] + '/todo.db'

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

      configure_data_mapper

      redis = nil
      begin
        EM.run do
          puts "starting eventmachine"

          start_workqueue
          start_rack_apps

          puts "eventmachine running"
        end
      rescue
        puts 'Error in EM.run loop:'
        puts $!, $!.backtrace.join("\n\t")
        exit 1
      ensure
        redis.close_connection unless redis.nil?
      end
    end

    def db_url
      @db_url || DEFAULT_DB_URL
    end

    def redis_url
      @redis_url || DEFAULT_REDIS_URL
    end

    def environment
      :development
    end

    def map(route, app)
      @rack_app_mappings ||= {}
      @rack_app_mappings[route] = app
    end

    def add_wq_event_handler(handler)
      @wq_handlers ||= []
      @wq_handlers << handler
      self
    end

    def rack_config
      @rack_config ||= {
        :server => 'thin',
        :Port => 8000,
        :signals => false
      }
    end

    private
    def configure_data_mapper
      puts 'configuring data_mapper'

      DataMapper::Logger.new($stdout, :debug)

      puts 'connecting datamapper :default -> %s' % db_url
      DataMapper.setup(:default, db_url);

      #DataMapper.auto_migrate!
      DataMapper
        .finalize
        .auto_upgrade!
      puts 'configured data_mapper'
    end

    def setup_redis_handlers
      raise 'EM reactor must be running to connect to redis' unless EM.reactor_running?

      puts 'connecting to redis at: %s' % redis_url
      redis = EM::Hiredis.connect redis_url
      puts 'connected to redis at: %s' % redis_url

      puts 'assigning redis to handlers'
      @wq_handlers.each do |handler|
        handler.redis = redis
      end
    end

    def start_workqueue
      puts "starting workqueue"

      setup_redis_handlers
      WQ::Runner.new(*@wq_handlers).setup_reactor_hooks

      puts "worqueue running"
    end

    def start_rack_apps
      return if @rack_app_mappings.nil?

      puts "starting rack apps"

      # assign to local for reference inside the block
      rack_app_mappings = @rack_app_mappings
      web_dispatch = Rack::Builder.app do
        use Rack::CommonLogger
        use Rack::Lint

        rack_app_mappings.each do |route, app|
          puts 'adding rack app mapping for root: %s' % route
          map(route) { run app }
        end

        map "/lobster" do
          run Rack::Lobster.new
        end
      end

      rack_config[:app] = web_dispatch
      Rack::Server.start rack_config

      puts "rack apps running"
    end

  end
end

unless $LOAD_PATH.include? './lib'
  $LOAD_PATH.unshift './lib'
end

require 'rack'
require 'rack/lobster'
require 'data_mapper'

require 'logging'
require 'workqueue'
require 'todo/model'

module Todo
  class App

    include Logging
    loglevel :debug
    set_as_parent_logger

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

      configure_logging
      configure_data_mapper

      redis = nil
      begin
        EM.run do
          log.debug "starting eventmachine"

          start_workqueue
          start_rack_apps

          log.info "eventmachine running"
        end
      rescue
        log.error 'Error in EM.run loop:'
        log.error $!, $!.backtrace.join("\n\t")
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
    def configure_logging
    end

    def configure_data_mapper
      log.debug 'configuring data_mapper'

      DataMapper::Logger.new($stdout, :debug)

      log.info 'connecting datamapper :default -> %s' % db_url
      DataMapper.setup(:default, db_url);

      log.debug 'running DataMapper::auto_upgrade!'
      #DataMapper.auto_migrate!
      DataMapper
        .finalize
        .auto_upgrade!
      log.debug 'configured data_mapper'
    end

    def setup_redis_handlers
      raise 'EM reactor must be running to connect to redis' unless EM.reactor_running?

      log.debug 'connecting to redis at: %s' % redis_url
      redis = EM::Hiredis.connect redis_url
      log.info 'connected to redis at: %s' % redis_url

      log.debug 'assigning redis to handlers'
      @wq_handlers.each do |handler|
        handler.redis = redis
      end
    end

    def start_workqueue
      log.debug "starting workqueue"

      setup_redis_handlers
      WQ::Runner.new(*@wq_handlers).setup_reactor_hooks

      log.info "worqueue running"
    end

    def start_rack_apps
      return if @rack_app_mappings.nil?

      log.debug "starting rack apps"

      # assign to local for reference inside the block
      rack_app_mappings = @rack_app_mappings
      logger = log

      web_dispatch = Rack::Builder.app do
        use Rack::CommonLogger
        use Rack::Lint

        rack_app_mappings.each do |route, app|
          logger.info 'adding rack app mapping for root: %s' % route
          map(route) { run app }
        end

        map "/lobster" do
          run Rack::Lobster.new
        end
      end

      rack_config[:app] = web_dispatch
      Rack::Server.start rack_config

      log.info "rack apps running"
    end

  end
end

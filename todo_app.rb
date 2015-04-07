unless $LOAD_PATH.include? './lib'
  $LOAD_PATH.unshift './lib'
end

require 'rack'
require 'data_mapper'

require 'logging'
require 'workqueue'
require 'todo/model'

module Todo
  class App

    include Logging
    setup_parent_logger(:info, :stdout)

    DEFAULT_REDIS_URL = 'redis://localhost:6379/'
    DEFAULT_DB_URL = 'sqlite3:///' + ENV['RUN_DIR'] + '/todo.db'

    attr_accessor :log_level
    attr_accessor :web_port, :web_host

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

      self.class.loglevel self.log_level

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
        log_fatal 'EM reactor loop', $!
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

      add_redis_consumer(handler) if handler.is_a? WQ::RedisConsumer

      self
    end

    def add_redis_consumer(redis_consumer)
      @redis_consumers ||= []
      @redis_consumers << redis_consumer
      self
    end

    def rack_config
      @rack_config ||= {
        :server => 'thin',
        :Port => self.web_port,
        :Host => self.web_host,
        :signals => false
      }
    end

    private
    def configure_logging
    end

    def configure_data_mapper
      log.debug 'configuring data_mapper'

      DataMapper::Logger.new($stdout, log_level)

      log.info 'connecting datamapper :default -> %s' % db_url
      DataMapper.setup(:default, db_url);

      log.debug 'running DataMapper::auto_upgrade!'
      #DataMapper.auto_migrate!
      DataMapper
        .finalize
        .auto_upgrade!
      log.debug 'configured data_mapper'
    end

    def setup_redis_consumers
      raise 'EM reactor must be running to connect to redis' unless EM.reactor_running?

      log.debug 'connecting to redis at: %s' % redis_url

      redis_deferrable = EM::DefaultDeferrable.new
      redis = EM::Hiredis.connect redis_url

      redis.on :connected do
        log.info 'connected to redis at: %s' % redis_url
        redis_deferrable.succeed
      end
      redis_deferrable.timeout 5, :timeout

      redis_deferrable.errback do |reason|
        case reason
        when :timeout
          raise 'failed to connect to redis in 5 seconds'
        else
          raise 'connectng to redis failed for unknown reason'
        end
      end

      redis_deferrable.callback do
        @redis_consumers.each do |consumer|
          log.info 'assigning redis to consumer: %s' % consumer
          consumer.redis = redis
        end
      end
    end

    def start_workqueue
      log.debug "starting workqueue"

      setup_redis_consumers
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
      end

      rack_config[:app] = web_dispatch
      Rack::Server.start rack_config

      log.info "rack apps running"
    end

  end
end

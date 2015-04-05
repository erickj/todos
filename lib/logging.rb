require 'log4r'
# Set the root logger level before any other loggers get defined, (e.g. during
# 'require log4r-color')
# see: http://log4r.rubyforge.org/rdoc/log4r/logger_rb.html
Log4r::Logger.global.level = Log4r::ALL

module Logging

  LEVELS = [:debug, :info, :warn, :error, :fatal, :all]

  def self.included(base)
    base.extend ClassMethods
  end

  def log
    self.class.logger
  end

  def log_error(context_name, error, lvl=:error)
    log.send lvl, "caught <%s> in <%s>:\n\t %s"%[error.class, context_name, error.message]
    log.send lvl, "stacktrace:\n\t" + error.backtrace.join("\n\t")
  end

  def log_fatal(context_name, error)
    log_error context_name, error, :fatal
  end

  module ClassMethods

    @@parent_logger_name = nil

    def setup_parent_logger(lvl=:all, output=nil)
      raise 'parent logger already set to %s' % @@parent_logger_name if @@parent_logger_name
      @@parent_logger_name = log4r_logger_name

      loglevel lvl
      add_logger_output output unless output.nil?
      logger.info "set %s as parent logger"%@@parent_logger_name
    end

    def loglevel(level=nil)
      if level.nil?
        return @loglevel || :all
      end

      raise 'unknown log level %s'%level unless LEVELS.any? { |lvl| lvl == level }
      @loglevel = level

      if @logger_created
        logger.level = log4r_level
        logger.info 'changed to log level: %s' % @loglevel
      end
    end

    def add_logger_output(output=:stdout)
      case output
      when :stdout
        logger.add Log4r::Outputter.stdout
      else
        raise 'unknown output %s' % output
      end
    end

    def logger
      logger_name = log4r_logger_name
      unless Log4r::Logger[logger_name]
        Log4r::Logger.new logger_name, log4r_level
        Log4r::Logger[logger_name].debug 'created logger %s'%logger_name
        @logger_created = true
      end
      Log4r::Logger.get logger_name
    end

    private
    def log4r_level
      case loglevel
      when :debug
        Log4r::DEBUG
      when :info
        Log4r::INFO
      when :warn
        Log4r::WARN
      when :error
        Log4r::ERROR
      when :fatal
        Log4r::FATAL
      when :all
        Log4r::ALL
      else
        raise ArgumentError, 'unknown log level %s'%@loglevel
      end
    end

    def log4r_logger_name
      logger_name = (self.name.nil? ? "<nil>" : self.name).downcase
      if @@parent_logger_name && logger_name != @@parent_logger_name
        logger_name = [@@parent_logger_name, logger_name].join '::'
      end
      logger_name
    end
  end

end

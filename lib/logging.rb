require 'log4r'
# Set the root logger level before any other loggers get defined, (e.g. during
# 'require log4r-color')
# see: http://log4r.rubyforge.org/rdoc/log4r/logger_rb.html
Log4r::Logger.global.level = Log4r::ALL

module Logging

  LEVELS = [:debug, :info, :warn, :error, :fatal]

  def self.included(base)
    base.extend ClassMethods
  end

  def log
    self.class.logger
  end

  module ClassMethods

    def loglevel(level)
      raise 'unknown log level %s'%level unless LEVELS.any? { |lvl| lvl == level }
      @loglevel = level
    end

    def set_as_parent_logger
      raise 'parent logger already set to %s' % @parent_logger_name if @parent_logger_name
      @parent_logger_name = log4r_logger_name
      logger.debug "set %s as parent logger"%@parent_logger_name
    end

    def logger
      logger_name = log4r_logger_name
      unless Log4r::Logger[logger_name]
        Log4r::Logger.new logger_name, log4r_level
        Log4r::Logger[logger_name].add Log4r::Outputter.stdout
        Log4r::Logger[logger_name].debug 'created logger %s'%logger_name
      end
      Log4r::Logger.get logger_name
    end

    private
    def log4r_level
      case @loglevel
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
      else
        raise ArgumentError, 'unknown log level %s'%@loglevel
      end
    end

    def log4r_logger_name
      logger_name = self.name.downcase
      if @parent_logger_name && logger_name != @parent_logger_name
        logger_name = [@parent_logger_name, logger_name].join '::'
      end
      logger_name
    end
  end

end

#!/bin/env ruby

unless $LOAD_PATH.include? '.'
  $LOAD_PATH.unshift '.'
end

require 'rubygems'
require 'bundler'

require 'optparse'
require 'yaml'

options = {
  :log_level => :debug,
  :port => 8000,
  :host => 'localhost',
  :env => :development
}

# see http://ruby-doc.org/stdlib-2.2.0/libdoc/optparse/rdoc/OptionParser.html
OptionParser.new do |opts|
  opts.banner = "Usage: run.rb [options]"
  opts.separator ""
  opts.separator "Option details:"

  # Cast 'port' argument to an Integer.
  opts.on('-H', '--host H', 'Webserver host') do |h|
    options[:host] = h
  end

  # Cast 'port' argument to an Integer.
  opts.on('-p', '--port P', Integer, 'Webserver port') do |p|
    options[:port] = p
  end

  # Logging verbosity
  opts.on('-e', '--env [ENVIRONMENT]', [:development, :production],
          'Choose environment (%s)'%[:development, :production].join(',')) do |e|
    options[:env] = e
  end

  # Logging verbosity
  log_levels = [:debug, :info, :warn, :error, :fatal]
  opts.on('-l', '--log-level [LEVEL]', log_levels,
          'Choose logging verbosity level (%s)'%log_levels.join(',')) do |l|
    options[:log_level] = l
  end

  # No argument, shows at tail.  This will print an options summary.
  opts.on("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.separator ''
  opts.separator 'Defaults:'
  opts.separator options.to_yaml
end.parse!

Bundler.require

require 'lib/logging'

# load ENV variables from .environment
if File.exists? ".environment"
  File.readlines(".environment").map { |line| line.rstrip.split(/=/) }.each do |pair|
    next if pair[0].nil? || pair[1].nil?
    ENV[pair[0]] = pair[1]
  end
end

ENV['RUN_DIR'] = File.join(Dir.home, 'tmp', 'todo');
unless Dir.exist?(ENV['RUN_DIR'])
  Dir.mkdir(ENV['RUN_DIR'], 0770)
  puts "Created %s" % ENV['RUN_DIR']
end

require 'todo_app'
require 'lib/app/debug_api'
require 'lib/app/mail_api'
require 'lib/app/web_api'
require 'lib/todo/mail/todo_mailer'

Todo::App.start do |app|

  app.log_level = options[:log_level]
  app.web_port = options[:port]
  app.web_host = options[:host]

  wq_event_handlers = []
  wq_event_handlers << Todo::Command::CommandSink.new
  wq_event_handlers.concat Todo::WebApi.workqueue_handlers
  wq_event_handlers.concat Todo::MailApi.workqueue_handlers

  wq_event_handlers.each { |h| app.add_wq_event_handler h }

  app.add_redis_consumer Todo::Mail::TodoMailer.new

  app.map '/debug'   , Todo::DebugApi.new
  app.map '/api'     , Todo::WebApi.new
  app.map '/mailapi' , Todo::MailApi.new
end

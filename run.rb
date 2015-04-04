#!/bin/env ruby

unless $LOAD_PATH.include? '.'
  $LOAD_PATH.unshift '.'
end

require 'rubygems'
require 'bundler'

Bundler.require

# load ENV variables from .environment
if File.exists? ".environment"
  File.readlines(".environment").map { |line| line.rstrip.split(/=/) }.each do |pair|
    ENV[pair[0]] = ENV[pair[1]]
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

Todo::App.start do |app|

  wq_event_handlers = []
  wq_event_handlers << Todo::Command::CommandSink.new
  wq_event_handlers.concat Todo::WebApi.workqueue_handlers
  wq_event_handlers.concat Todo::MailApi.workqueue_handlers

  wq_event_handlers.each { |h| app.add_wq_event_handler h }

  app.map '/debug'   , Todo::DebugApi.new
  app.map '/api'     , Todo::WebApi.new
  app.map '/mailapi' , Todo::MailApi.new
end

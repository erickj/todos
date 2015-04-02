unless $LOAD_PATH.include? '.'
  $LOAD_PATH.unshift '.'
end

require 'rubygems'
require 'bundler'
require 'rack'

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

require 'lib/app/mail_api'
require 'lib/app/web_api'

Todo::App.start do |app|

  app.add_wq_event_handler Todo::Command::CommandSink.new
  app.add_wq_event_handlers Todo::WebApi.workqueue_handlers
#  app.add_wq_event_handlers Todo::MailApi.workqueue_handlers

  app.map '/api', Todo::WebApi.new
#  app.add_mapping '/mailapi', Todo::MailApi.new

#  run(Rack::URLMap.new(
#       app.web_root + "/api" => Todo::Api,
#       app.web_root + "/mailapi" => Todo::MailApi))
end

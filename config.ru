unless $LOAD_PATH.include? '.'
  $LOAD_PATH.unshift '.'
end

require 'rubygems'
require 'bundler'
require 'rack'

Bundler.require

ENV['RUN_DIR'] = File.join(Dir.home, 'tmp', 'todo');
unless Dir.exist?(ENV['RUN_DIR'])
  Dir.mkdir(ENV['RUN_DIR'], 0770)
  puts "Created %s" % ENV['RUN_DIR']
end

require 'todo_app'
require 'lib/api'
require 'lib/mail_api'

Todo::App.start do |app|

  app.add_wq_event_handlers(Todo::Api.workqueue_handlers)
  app.add_wq_event_handlers(Todo::MailApi.workqueue_handlers)

  run(Rack::URLMap.new(
       app.web_root + "/api" => Todo::Api,
       app.web_root + "/mailapi" => Todo::MailApi))
end

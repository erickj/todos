unless $LOAD_PATH.include? '.'
  $LOAD_PATH.unshift '.'
end

require 'rubygems'
require 'bundler'

Bundler.require


ENV['RUN_DIR'] = File.join(Dir.home, 'tmp', 'todo');
unless Dir.exist?(ENV['RUN_DIR'])
  Dir.mkdir(ENV['RUN_DIR'], 0770)
  puts "Created %s" % ENV['RUN_DIR']
end

require './todo_app.rb'
run Todo::App

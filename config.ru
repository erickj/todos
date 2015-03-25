unless $LOAD_PATH.include? '.'
  $LOAD_PATH.unshift '.'
end

require 'rubygems'
require 'bundler'

Bundler.require

require './todo_app.rb'
run Todo::App

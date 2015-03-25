unless $LOAD_PATH.include? './lib'
  $LOAD_PATH.unshift './lib'
end

require 'data_mapper'
require 'json'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3:///' + ENV['RUN_DIR'] + '/todo.db');

# Todo requires
require 'model'

module Todo
  class App < Sinatra::Base

    get '/todo' do
      templates = Todo::Template.all(:limit => 10);
      templates.to_json
    end

    get '/todo/:id' do
      template = Todo::Template.get(params[:id])
      if template.nil?
        return [404, "Todo Not Found"]
      else
        template.to_json
      end
    end

    put '/todo/:id' do
      todo_json = JSON.parse(request.body.read)
      todo = Todo::Template.create(todo_json)
      todo.to_json
    end
  end
end

#DataMapper.auto_migrate!
DataMapper
  .finalize
  .auto_upgrade!

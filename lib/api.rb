require 'model'

module Todo
  class Api < Sinatra::Base

    get '/' do
      'api'
    end

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

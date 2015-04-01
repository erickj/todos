require 'json'
require 'todo/command'
require 'todo/model'

module Todo
  class Api < Sinatra::Base

    class << self
      def workqueue_handlers
        [ ]
      end
    end

    get '/' do
      'api'
    end

    get '/todo' do
      templates = Todo::Model::TodoTemplate.all(:limit => 10);
      templates.to_json
    end

    put '/todo' do
      request.body.rewind
      todo_json = JSON.parse(request.body.read, :symbolize_names => true)
      cmd = Todo::Command::CreateTodoCommand.build(
        todo_json[:email],
        todo_json[:title],
        todo_json[:description])
      todo = Todo::Command::CreateTodoCommandProcessor.new.process(cmd)
      redirect request.fullpath + '/' + todo.id.to_s
    end

    get '/todo/:id' do
      template = Todo::Model::TodoTemplate.get(params[:id])
      if template.nil?
        return [404, "Todo Not Found"]
      else
        template.to_json
      end
    end

    get '/todo/owner/:id' do
      person = Todo::Model::Person.get(params[:id])
      if person.nil?
        return [404, "Todo Not Found"]
      else
        person.to_json
      end
    end

  end
end

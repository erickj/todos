require 'json'
require 'todo/command'
require 'todo/model'

module Todo
  class Api < Sinatra::Base

    COMMAND_SOURCE = Todo::Command::CommandSource.new

    configure do
      set :threaded, false
    end

    class << self
      def workqueue_handlers
        [ COMMAND_SOURCE ]
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
      cmd = Todo::Command::CreateTodo::Command.build({
                                                       :owner_email => todo_json[:email],
                                                       :title => todo_json[:title],
                                                       :description => todo_json[:description]
                                                     })
      COMMAND_SOURCE << cmd
      [202]
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

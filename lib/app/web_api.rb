require 'json'
require 'todo/command'
require 'todo/model'
require 'uri'

module Todo
  class WebApi < Sinatra::Base

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
      puts params.to_yaml

      todo_events_json = JSON.parse(URI.decode(params[:events]), :symbolize_names => true)
      todo_events_json.each do |todo_json|
        cmd = Todo::Command::CreateTodo::Command.build({
                                                         :owner_email => todo_json[:email],
                                                         :title => todo_json[:title],
                                                         :description => todo_json[:description]
                                                       })
        COMMAND_SOURCE << cmd
      end
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

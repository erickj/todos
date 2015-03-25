require 'sinatra/base'

class TodoApp < Sinatra::Application
  get '/todo/:id' do
    'Todo %s' % params[:id]
  end
end

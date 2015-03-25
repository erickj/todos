unless $LOAD_PATH.include? './lib'
  $LOAD_PATH.unshift './lib'
end

#require 'todo/controller'

module Todo
  class App < Sinatra::Base

    get '/todo/:id' do
      'Todo %s' % params[:id]
    end

  end
end

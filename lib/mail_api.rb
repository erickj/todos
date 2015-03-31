require 'model'

module Todo
  class MailApi < Sinatra::Base

    class << self
      def workqueue_handlers
        [ ]
      end
    end

    get '/' do
      'mail API'
    end

    head '/mail' do
      200
    end

    get '/mail' do
      'request to /mail'
    end

    post '/mail' do
      request.body.rewind
      puts "/mail request body"
      puts request.body.read
    end

  end
end

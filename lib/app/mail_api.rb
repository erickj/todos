require 'json'
require 'todo/model'
require 'uri'

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
      parts = request.body.read.split(/=/, 2)
      mandril_events_json = URI.decode parts[1]
      puts JSON.pretty_generate JSON.parse(mandril_events_json)
    end

  end
end

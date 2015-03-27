require 'model'

module Todo
  class MailApi < Sinatra::Base

    get '/' do
      'mail API'
    end

  end
end

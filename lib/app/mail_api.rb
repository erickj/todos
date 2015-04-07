require 'json'
require 'todo/command'
require 'uri'
require 'logging'

module Todo
  class MailApi < Sinatra::Base

    COMMAND_SOURCE = Todo::Command::CommandSource.new

    class << self
      def workqueue_handlers
        [ COMMAND_SOURCE ]
      end
    end

    disable :show_exceptions

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
      content_type :"application/json"

      request.body.rewind
      raw_mandrill_events = URI.decode params[:mandrill_events]
      json_events = JSON.parse raw_mandrill_events, :symbolize_names => true
      process_mail_events json_events

      [200, JSON.pretty_generate(json_events)]
    end

    private
    def process_mail_events(json_events)
      json_events.each do |json_event|
        case json_event[:event]
        when 'inbound'
          process_inbound_mail_event json_event
        else
          raise 'unknown event type %s' % json_event[:event]
        end
      end
    end

    # see http://help.mandrill.com/entries/22092308-What-is-the-format-of-inbound-email-webhooks-
    def process_inbound_mail_event(json_event)
      title = URI.decode_www_form_component json_event[:msg][:subject]
      description = URI.decode_www_form_component json_event[:msg][:text]
      owner_email = URI.decode_www_form_component json_event[:msg][:from_email]

      COMMAND_SOURCE << Todo::Command::CreateTodo::Command.build({
                                                                   :owner_email => owner_email,
                                                                   :title => title,
                                                                   :description => description
                                                                 })
    end
  end
end

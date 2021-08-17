require 'json'
require 'todo/command'
require 'todo/mail'
require 'logging'
require 'uri'

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
    def process_mandrill_events(uri_encoded_mandrill_events)
      json_events = JSON.parse URI.decode(uri_encoded_mandrill_events), :symbolize_names => true
      inbound_messages = Todo::Mail::InboundMaillMessage::MandrillBuilder.build_from_json_events json_events
      inbound_messages.each do |message|
        COMMAND_SOURCE << build_task_from_message(message)
      end
    end

    def build_task_from_message(inbound_message)
      from_user = inbound_message.from_persona.user
      task_type, task_data = case from_user
#                             when 'list'
#                               create_get_list_event json_event
                             when 'todo'
                               [
                                 Todo::Command::TaskType::CREATE_TODO,
                                 message_to_create_todo_task_data(inbound_message)
                               ]
#                             when /^todo\+[.]+/
#                               create_update_todo_event json_event
                             else
                               raise 'unknown from email %s' % from_user
                             end

      task_builder = Todo::Command::CommandBuilder.builder_for task_type
      task_builder.build task_data
    end

    def message_to_create_todo_task_data(inbound_message)
      {
        :creator_email => inbound_message.from.email,
        :title => decode_value(inbound_message.msg_subject),
        :description => decode_value(inbound_message.msg_text)
      }
    end

    private
    def decode_value(value)
      URI.decode_www_form_component value
    end

  end
end

module Todo
  module Mail
    class InboundMailMessage

      class MandrillBuilder
        class << self
          # see http://help.mandrill.com/entries/22092308-What-is-the-format-of-inbound-email-webhooks-
          def build_from_json_events(json_events)
            json_events.map do |json_event|
              event_type = json_event[:event]
              raise 'invalid event type: %s' % event unless event_type == 'inbound'

              mandrill_event_msg = json_event[:msg]

              service_persona = Persona.new mandrill_event_msg[:email]

              from_persona = Persona.new mandrill_event_msg[:from_email], mandrill_event_msg[:from_name]

              to_personas = mandrill_event_msg[:to].nil? ? [] : mandrill_event_msg[:to].map do |pair|
                Persona.new pair[0], pair[1]
              end

              cc_personas = mandrill_event_msg[:cc].nil? ? [] : mandrill_event_msg[:cc].map do |pair|
                Persona.new pair[0], pair[1]
              end

              InboundMailMessage.new(
                service_persona,
                from_persona,
                to_personas,
                cc_personas,
                mandrill_event_msg[:subject],
                mandrill_event_msg[:text]
              )
            end
          end
        end
      end

      attr_reader :service_persona, :from_persona, :to_personas, :cc_personas, :msg_subject, :msg_text

      def initialize(service_persona, from_persona, to_personas, cc_personas, msg_subject, msg_text)
        @service_persona = service_persona
        @from_persona = from_persona
        @to_personas = to_personas
        @cc_personas = cc_personas
        @msg_subject = msg_subject
        @msg_text = msg_text
      end

    end
  end
end

require 'todo/mail'

RSpec.describe Todo::Mail::InboundMailMessage, :mail do

  let(:service_persona) { Todo::Mail::Persona.new 'service@domain.com' }
  let(:from_persona) { Todo::Mail::Persona.new 'from@person.com' }
  let(:to_personas) { [ Todo::Mail::Persona.new('to@a.com'), Todo::Mail::Persona.new('to@b.com') ] }
  let(:cc_personas) { [ Todo::Mail::Persona.new('cc@a.com'), Todo::Mail::Persona.new('cc@b.com') ] }

  subject do
    Todo::Mail::InboundMailMessage.new(
      service_persona,
      from_persona,
      to_personas,
      cc_personas,
      'the most important subject ever',
      'the shnozberries taste like shnozberries'
    )
  end

  it 'should respond to service_persona' do
    expect(subject.service_persona).to be == service_persona
  end

  it 'should respond to from_persona' do
    expect(subject.from_persona).to be == from_persona
  end

  it 'should respond to to_personas' do
    expect(subject.to_personas).to be == to_personas
  end

  it 'should respond to cc_personas' do
    expect(subject.cc_personas).to be == cc_personas
  end

  it 'should respond to msg_subject' do
    expect(subject.msg_subject).to be == 'the most important subject ever'
  end

  it 'should respond to msg_text' do
    expect(subject.msg_text).to be == 'the shnozberries taste like shnozberries'
  end

  context Todo::Mail::InboundMailMessage::MandrillBuilder do

    let(:json_events) do
      raw = File.read('./spec/example_data/mandrill_inbound_multi_recipients.json')
      JSON.parse URI.decode(raw), :symbolize_names => true
    end

    subject do
      Todo::Mail::InboundMailMessage::MandrillBuilder.build_from_json_events(json_events).first
    end

    it 'should set service persona' do
      expect(subject.service_persona.email).to be == 'todo@todo.service.domain'
      expect(subject.service_persona.name).to be_empty
    end

    it 'should set from persona' do
      expect(subject.from_persona.email).to be == 'from@gmail.com'
      expect(subject.from_persona.name).to be == 'Frim From'
    end

    it 'should set to personas' do
      expect(subject.to_personas.size).to be 2

      expect(subject.to_personas.first.email).to be == 'todo@todo.service.domain'
      expect(subject.to_personas.first.name).to be_empty

      expect(subject.to_personas.last.email).to be == 'to@eie.io'
      expect(subject.to_personas.last.name).to be == 'Timbuk To'
    end

    it 'should set cc personas' do
      expect(subject.cc_personas.size).to be 1

      expect(subject.cc_personas.first.email).to be == 'cc@gmail.com'
      expect(subject.cc_personas.first.name).to be == 'Cecil CC'
    end

    it 'should set message subject' do
      expect(subject.msg_subject).to be == 'coconuts'
    end

    it 'should set message text' do
      expect(subject.msg_text).to be == "I have a lovely bunch of coconuts\n\n"
    end
  end
end

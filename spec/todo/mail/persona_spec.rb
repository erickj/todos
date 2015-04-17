require 'todo/mail'

RSpec.describe Todo::Mail::Persona, :mail do

  subject { Todo::Mail::Persona.new 'e@j.com', 'Edge Rock' }

  it 'should respond to email' do
    expect(subject.email).to be == 'e@j.com'
  end

  it 'should respond to name' do
    expect(subject.name).to be == 'Edge Rock'
  end

  it 'should be == to Personas with like emails' do
    other = Todo::Mail::Persona.new 'e@j.com', nil
    expect(subject).to be == other
  end

  it 'should be unlike Personas with different emails' do
    other = Todo::Mail::Persona.new 'not.e@j.com', nil
    expect(subject).to_not be == other
  end

  it 'should parse off the email username' do
    expect(subject.username).to be == 'e'
  end

  it 'should set nil name to empty string' do
    expect(Todo::Mail::Persona.new('e@j.com', nil).name).to be_empty
  end
end

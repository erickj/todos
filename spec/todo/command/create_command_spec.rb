require 'shared/task_context'
require 'todo/command'

describe Todo::Command::CreateTodo::Command, :command do

  include_context 'a task'

  subject { Todo::Command::CreateTodo::Command.build 'e@j.com', 'a title', 'a description' }

  it 'has a builder method' do
    expect(subject.owner_email).to eql 'e@j.com'
    expect(subject.title).to eql 'a title'
    expect(subject.description).to eql 'a description'
  end

  it 'has task type CREATE_TODO' do
    expect(subject).to be =~ Todo::Command::TaskType::CREATE_TODO
  end

  it 'is (de)serializable' do
    serialized_command = serialize_task(subject)
    expect(deserialize_task(serialized_command)).to_not be subject
    expect(deserialize_task(serialized_command)).to be == subject
  end

  context Todo::Command::CreateTodo::Processor do

    let(:processor) { Todo::Command::CreateTodo::Processor.new }

    it 'raises an argument error for non CreateTodoCommand tasks' do
      bad_task = WQ::Task.new
      expect do
        processor.process_command bad_task
      end.to raise_error ArgumentError, /^can not process command of type/
    end

    it 'creates an owner if one does not exist' do
      todo_template = processor.process_command subject
      person = Todo::Model::Person.get!(1)

      expect(person).to eql todo_template.owner
    end

    it 'creates a saved todo template with the correct title and description' do
      todo_template = processor.process_command subject

      expect(todo_template.saved?).to be
      expect(todo_template.dirty?).to be false
      expect(todo_template.description).to eql 'a description'
      expect(todo_template.title).to eql 'a title'
    end
  end
end

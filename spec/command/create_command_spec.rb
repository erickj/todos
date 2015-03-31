require 'shared/task_context'
require 'todo/command'

describe Todo::Command::CreateTodoCommand, :command do

  include_context 'a task'

  let(:command) { Todo::Command::CreateTodoCommand.build 'e@j.com', 'a title', 'a description' }

  it 'has a builder method' do
    command = Todo::Command::CreateTodoCommand.build 'e@j.com', 'a title', 'a description'

    expect(command.owner_email).to eql 'e@j.com'
    expect(command.title).to eql 'a title'
    expect(command.description).to eql 'a description'
  end

  it 'has task type CREATE_TODO' do
    expect(Todo::Command::CreateTodoCommand.new.task_type).to be Todo::Command::TaskType::CREATE_TODO
  end

  it 'is (de)serializable' do
    serialized_command = serialize_task(command)
    expect(deserialize_task(serialized_command)).to_not be command
    expect(deserialize_task(serialized_command)).to be == command
  end

  context Todo::Command::CreateTodoCommandProcessor do

    let(:processor) { Todo::Command::CreateTodoCommandProcessor.new }

    it 'raises an argument error for non CreateTodoCommand tasks' do
      bad_task = WQ::Task.new
      expect do
        processor.process bad_task
      end.to raise_error ArgumentError, 'not a create command'
    end

    it 'creates an owner if one does not exist' do
      todo_template = processor.process command
      person = Todo::Model::Person.get!(1)

      expect(person).to eql todo_template.owner
    end

    it 'creates a saved todo template with the correct title and description' do
      todo_template = processor.process command

      expect(todo_template.saved?).to be
      expect(todo_template.dirty?).to be false
      expect(todo_template.description).to eql 'a description'
      expect(todo_template.title).to eql 'a title'
    end
  end
end

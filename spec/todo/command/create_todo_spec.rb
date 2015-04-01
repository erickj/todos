require 'dm-aggregates'
require 'shared/task_context'
require 'todo/command'

describe Todo::Command::CreateTodo::Command, :command do

  include_context 'a task'

  subject do Todo::Command::CreateTodo::Command.build({
                                                        :owner_email => 'e@j.com',
                                                        :title => 'a title',
                                                        :description => 'a description'
                                                      })
  end

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

    it 'completes successfully' do
      task_result = processor.process_command subject
      expect(task_result.is_success?).to be
    end

    it 'creates an owner if one does not exist' do
      expect(Todo::Model::Person.count).to be 0

      processor.process_command subject

      expect(Todo::Model::Person.count).to be 1
    end

    it 'doesn\'t create an owner if one already exists' do
      Todo::Model::Person.create :email => 'e@j.com'
      expect(Todo::Model::Person.count).to be 1

      processor.process_command subject

      expect(Todo::Model::Person.count).to be 1
    end

    it 'creates a saved todo template with the correct title and description' do
      task_result = processor.process_command subject
      todo_template = Todo::Model::TodoTemplate.by_uuid! task_result.result_key

      expect(todo_template.saved?).to be
      expect(todo_template.dirty?).to be false
      expect(todo_template.description).to eql 'a description'
      expect(todo_template.title).to eql 'a title'
    end
  end
end

require 'dm-aggregates'
require 'shared/task_context'
require 'todo/command'

RSpec.describe Todo::Command::CreateTodo::Command, :command do

  include_context 'a task'

  let(:data) {{
                :owner_email => 'e@j.com',
                :title => 'a title',
                :description => 'a description',
                :collaborator_emails => [
                  'a@collab.com', 'b@collab.com'
                ]
              }}

  subject { Todo::Command::CreateTodo::Command.build data }

  it 'has a builder method' do
    expect(subject.owner_email).to eql 'e@j.com'
    expect(subject.title).to eql 'a title'
    expect(subject.description).to eql 'a description'
    expect(subject.collaborator_emails).to eql ['a@collab.com', 'b@collab.com']
  end

  it 'has task type CREATE_TODO' do
    expect(subject).to be =~ Todo::Command::TaskType::CREATE_TODO
  end

  it 'is (de)serializable' do
    serialized_command = serialize_task(subject)
    expect(deserialize_task(serialized_command)).to_not be subject
    expect(deserialize_task(serialized_command)).to be == subject
  end

  context 'with creator email' do
    let(:creator_data) { data.merge :creator_email => 'c@creator.com' }

    subject { Todo::Command::CreateTodo::Command.build creator_data }

    it 'builds a task' do
      expect(subject.owner_email).to eql 'e@j.com'
      expect(subject.creator_email).to eql 'c@creator.com'
    end
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

      data[:collaborator_emails] = []
      task_result = processor.process_command subject

      expect(Todo::Model::Person.count).to be 1

      expect(task_result.result[:new_users].size).to be 1
      expect(Todo::Model.task_result_hash_to_model task_result.result[:new_users].first)
        .to be == Todo::Model::Person.first(:email => 'e@j.com')
    end

    it 'doesn\'t create an owner if one already exists' do
      Todo::Model::Person.create :email => 'e@j.com'
      expect(Todo::Model::Person.count).to be 1

      data[:collaborator_emails] = []
      task_result = processor.process_command subject

      expect(Todo::Model::Person.count).to be 1
      expect(task_result.result[:new_users]).to be_empty
    end

    it 'creates a saved todo template with the correct title and description' do
      task_result = processor.process_command subject
      todo_template = Todo::Model.task_result_hash_to_model task_result.result[:todo_template]

      expect(todo_template.saved?).to be
      expect(todo_template.dirty?).to be false
      expect(todo_template.description).to eql 'a description'
      expect(todo_template.title).to eql 'a title'
    end

    context 'without a creator' do
      it 'should use the owner as the creator' do
        task_result = processor.process_command subject
        todo_template = Todo::Model.task_result_hash_to_model task_result.result[:todo_template]

        expect(todo_template.owner).to be == todo_template.creator
      end
    end

    context 'with a creator' do
      let(:creator_data) { data.merge :creator_email => 'c@creator.com' }

      subject { Todo::Command::CreateTodo::Command.build creator_data }

      it 'should create a creator ' do
        task_result = processor.process_command subject
        todo_template = Todo::Model.task_result_hash_to_model task_result.result[:todo_template]

        expect(todo_template.creator.email).to be == 'c@creator.com'
        expect(todo_template.owner.email).to be == 'e@j.com'
      end
    end

    context 'with collaborators' do
      it 'should create collaborators' do
        Todo::Model::Person.create :email => 'e@j.com'
        expect(Todo::Model::Person.count).to be 1

        task_result = processor.process_command subject
        todo_template = Todo::Model.task_result_hash_to_model task_result.result[:todo_template]

        expect(Todo::Model::Person.count).to be 3
        expect(todo_template.collaborators[0].email).to be == 'a@collab.com'
        expect(todo_template.collaborators[1].email).to be == 'b@collab.com'

        expect(task_result.result[:new_users].size).to be 2
        expect(Todo::Model.task_result_hash_to_model task_result.result[:new_users][0])
          .to be == todo_template.collaborators[0]
        expect(Todo::Model.task_result_hash_to_model task_result.result[:new_users][1])
          .to be == todo_template.collaborators[1]
      end
    end
  end
end

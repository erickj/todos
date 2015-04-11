require 'securerandom'
require 'todo/model'
require 'uuidtools'

RSpec.describe Todo::Model::TodoTemplate, :model do

  it_behaves_like 'a model'
  it_behaves_like 'a UUID model'

  let :owner do
    Todo::Model::Person.create :email => '%d@j.com' % rand(0..100000)
  end

  let :data do
    {
      :title => 'A fantastically important TODO',
      :description => 'Get all my stuff done!',
      :owner => owner
    }
  end

  subject do
    Todo::Model::TodoTemplate.create data
  end

  context 'properties' do

    it 'should have a title' do
      expect(subject.title).to eql 'A fantastically important TODO'
    end

    it 'should have a description' do
      expect(subject.description).to eql 'Get all my stuff done!'
    end

    it 'should have a default state of :todo' do
      expect(subject.state).to be :todo
    end

    it 'should allow state :done' do
      subject.update :state => :done
      expect(subject.state).to be :done
    end

    it 'should be indexed on state' do
      subject # access the subject to force the insert
      todos = Todo::Model::TodoTemplate.all :state => :todo
      expect(todos.first).to eql subject
    end
  end

  context 'associations' do

    before :each do
      DataMapper::Model.raise_on_save_failure = false
    end

    it 'should have a creator', :x do
      expect(subject.creator).to eql owner
    end

    it 'should have an owner' do
      expect(subject.owner).to eql owner
    end

    it 'should require an owner' do
      data.delete :owner
      broken_model = Todo::Model::TodoTemplate.create data
      expect(broken_model.saved?).not_to be

      expect(broken_model.errors[:owner_id].size).to be 1
      expect(broken_model.errors[:owner_id].first).to be =~ /must not be blank$/
    end

    it 'should have many template attachments' do
      expect(subject.template_attachments).to be_empty

      attatchment = Todo::Model::TemplateAttachment.create({
        :mime_type => 'text/plain',
        :name => 'anattatchment.txt',
        :content => 'I have a lovely bunch of cocunuts'
      })
      subject.template_attachments << attatchment
      subject.save
      expect(subject.template_attachments).to_not be_empty
    end

    it 'should have a default recurrence rule' do
      expect(subject.recurrence_rules.size).to be 1

      rule = subject.recurrence_rules[0]
      expect(rule.start_time.to_i).to be_within(1).of Time.now.to_i
      expect(rule.count).to be 1
    end

    it 'should have n collaborator assignments' do
      expect(subject.collaborator_assignments).to be_empty

      collaborator1 = Todo::Model::Person.create :email => 'collab1.%d@j.com' % rand(0..100000)
      assignment1 = Todo::Model::CollaboratorAssignment.create({
        :person => collaborator1,
        :todo_template => subject
      })

      collaborator2 = Todo::Model::Person.create :email => 'collab2.%d@j.com' % rand(0..100000)
      assignment2 = Todo::Model::CollaboratorAssignment.create({
        :person => collaborator2,
        :todo_template => subject
      })

      expect(subject.collaborator_assignments.reload).to_not be_empty

      expect(subject.collaborator_assignments[0]).to be == assignment1
      expect(subject.collaborators[0]).to be == collaborator1

      expect(subject.collaborator_assignments[1]).to be == assignment2
      expect(subject.collaborators[1]).to be == collaborator2
    end

    it 'should add collaborators as collaborator assignments' do
      expect(subject.collaborators).to be_empty
      expect(subject.collaborator_assignments).to be_empty

      collaborator = Todo::Model::Person.create :email => 'collab1.%d@j.com' % rand(0..100000)
      subject.collaborators << collaborator

      expect(subject.collaborators).to_not be_empty
      expect(subject.collaborator_assignments).to be_empty

      expect(subject.collaborators.first).to be == collaborator
    end
  end

  context 'views' do

    it 'should be viewable as json' do
      expect(subject.to_json).to be_a String
      expect(subject.to_json).to eql({
        :id => 1,
        :uuid => subject.uuid.to_s,
        :state => 'todo',
        :title => 'A fantastically important TODO',
        :description => 'Get all my stuff done!',
        :created_at => subject.created_at,
        :owner_id => subject.owner_id,
        :creator_id => subject.owner_id
      }.to_json)
    end
  end

  context 'creator is not the owner' do

    let(:creator) { Todo::Model::Person.create :email => 'creator.%d@j.com' % rand(0..100000) }

    let!(:creators_todo) do
      data[:creator] = creator
      Todo::Model::TodoTemplate.create data
    end

    it 'should not be created by the owner' do
      expect(creator).to_not eql owner
      expect(creators_todo.creator).to eql creator
      expect(creators_todo.owner).to eql owner
    end

    it 'should be indexed on creator' do
      todo = Todo::Model::TodoTemplate.first :creator => creator
      expect(todo).to eql creators_todo
    end
  end
end

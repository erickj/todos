require 'securerandom'
require 'shared/model_examples'
require 'todo/model'
require 'uuidtools'

describe Todo::Model::TodoTemplate, :model do

  it_behaves_like 'a model'

  let :data do
    {
      :title => 'A fantastically important TODO',
      :description => 'Get all my stuff done!',
      :owner => Todo::Model::Person.get!(1)
    }
  end

  let!(:model) do
    Todo::Model::Person.create :email => '%d@j.com' % rand(0..100000)
    Todo::Model::TodoTemplate.create data
  end

  context 'properties' do

    it 'should have a title' do
      expect(model.title).to eql 'A fantastically important TODO'
    end

    it 'should have a description' do
      expect(model.description).to eql 'Get all my stuff done!'
    end

    it 'should have a default state of :todo' do
      expect(model.state).to be :todo
    end

    it 'should allow state :done' do
      model.update :state => :done
      expect(model.state).to be :done
    end

    it 'should be indexed on state' do
      todos = Todo::Model::TodoTemplate.all :state => :todo
      expect(todos.first).to eql model
    end

    it 'should have a UUID' do
      expect(model.uuid).to be_a UUIDTools::UUID
    end
  end

  context 'keys' do
    it 'should be indexed on uuid' do
      todo_templates = Todo::Model::TodoTemplate.all :uuid => model.uuid
      expect(todo_templates.size).to be 1
      expect(todo_templates.first).to eql model
    end

    it 'should be accessible via +by_uuid+' do
      todo_template = Todo::Model::TodoTemplate.by_uuid model.uuid
      expect(todo_template).to eql model
    end

    it 'should throw on +by_uuid!+ for missing models' do
      expect do
        Todo::Model::TodoTemplate.by_uuid! SecureRandom.uuid
      end.to raise_error(/^missing TodoTemplate/)
    end
  end

  context 'associations' do

    before :each do
      DataMapper::Model.raise_on_save_failure = false
    end

    it 'should have an owner' do
      owner = Todo::Model::Person.get!(1)
      expect(model.owner).to eql owner
    end

    it 'should require an owner' do
      data.delete :owner
      broken_model = Todo::Model::TodoTemplate.create data
      expect(broken_model.saved?).not_to be

      expect(broken_model.errors[:owner_id].size).to be 1
      expect(broken_model.errors[:owner_id].first).to be =~ /must not be blank$/
    end

    it 'should have many template attachments' do
      expect(model.template_attachments).to be_empty

      attatchment = Todo::Model::TemplateAttachment.create({
        :mime_type => 'text/plain',
        :name => 'anattatchment.txt',
        :content => 'I have a lovely bunch of cocunuts'
      })
      model.template_attachments << attatchment
      model.save
      expect(model.template_attachments).to_not be_empty
    end

    it 'should have a default recurrence rule' do
      expect(model.recurrence_rules.size).to be 1

      rule = model.recurrence_rules[0]
      expect(rule.start_time.to_i).to be_within(1).of Time.now.to_i
      expect(rule.count).to be 1
    end
  end

  context 'views' do

    it 'should be viewable as json' do
      expect(model.to_json).to be_a String
      expect(model.to_json).to eql({
        :id => 1,
        :uuid => model.uuid.to_s,
        :state => 'todo',
        :title => 'A fantastically important TODO',
        :description => 'Get all my stuff done!',
        :created_at => model.created_at,
        :owner_id => model.owner_id
      }.to_json)
    end
  end
end

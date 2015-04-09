require 'shared/model_examples'
require 'todo/model'

describe Todo::Model::Person, :model do

  it_behaves_like 'a model'
  it_behaves_like 'a UUID model'

  let :data do
    {
      :name => 'EJ',
      :email => 'e@j.com'
    }
  end

  # Use #let! so that the model is creatd in a +before+ :each hook,
  # this prevents needing to access the :model variable before it's
  # created
  subject { Todo::Model::Person.create(data) }

  context 'properties' do

    it 'should have a name' do
      expect(subject.name).to eq 'EJ'
    end

    it 'should have an email' do
      expect(subject.email).to eq 'e@j.com'
    end
  end

  context 'keys' do

    before :each do
      DataMapper::Model.raise_on_save_failure = false
    end

    it 'should be indexed on email' do
      modelView = Todo::Model::Person.first :email => subject.email
      expect(modelView.name).to eql 'EJ'
      expect(modelView.email).to eql 'e@j.com'
    end

    it 'should be unique on email' do
      expect do
        Todo::Model::Person.create :email => subject.email
      end.to raise_error DataObjects::IntegrityError, /^UNIQUE constraint failed/
    end

    it 'should require email' do
      broken_model = Todo::Model::Person.create :name => 'Missing Email'
      expect(broken_model.saved?).to_not be
      expect(broken_model.errors[:email].size).to be 1
      expect(broken_model.errors[:email].first).to be =~ /must not be blank$/
    end
  end

  context 'associations' do

    it 'should have many todo templates' do
      expect(subject.todo_templates).to be_an Array

      subject.todo_templates << Todo::Model::TodoTemplate.new
      expect(subject.todo_templates.size).to be 1
      expect(subject.dirty?).to be
    end
  end
end

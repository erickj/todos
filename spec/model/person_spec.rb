require 'shared_examples/model'
require 'model'

describe Todo::Model::Person, :model do

  it_behaves_like 'a model'

  let :data do
    {
      :name => 'EJ',
      :email => 'e@j.com'
    }
  end

  context 'a Person model' do

    # Use #let! so that the model is creatd in a +before+ :each hook,
    # this prevents needing to access the :model variable before it's
    # created
    let!(:model) { Todo::Model::Person.create(data) }

    it 'should have a name' do
      expect(model.name).to eq 'EJ'
    end

    it 'should have an email' do
      expect(model.email).to eq 'e@j.com'
    end

    it 'should have many todo templates' do
      expect(model.todo_templates).to be_an Array

      model.todo_templates << Todo::Model::TodoTemplate.new
      expect(model.todo_templates.size).to be 1
      expect(model.dirty?).to be
    end


    context 'keys' do

      it 'should be indexed on email' do
        modelView = Todo::Model::Person.first :email => 'e@j.com'
        expect(modelView.name).to eql 'EJ'
        expect(modelView.email).to eql 'e@j.com'
      end

      it 'should be unique' do
        expect do
          Todo::Model::Person.create :email => data[:email]
        end.to raise_error DataObjects::IntegrityError, /^UNIQUE constraint failed/
      end

      it 'should be required' do
        expect do
          Todo::Model::Person.create :name => 'Missing Email'
        end.to raise_error DataMapper::SaveFailureError
      end
    end
  end
end

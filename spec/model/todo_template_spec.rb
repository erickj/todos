require 'shared_examples/model'
require 'model'

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
  end
end

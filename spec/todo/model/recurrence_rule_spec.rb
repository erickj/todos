require 'shared/model_examples'
require 'todo/model'

RSpec.describe Todo::Model::RecurrenceRule, :model do

  it_behaves_like 'a model'

  let!(:model) do
    owner = Todo::Model::Person.create :email => '%d@j.com' % rand(0..100000)
    todo = Todo::Model::TodoTemplate.create :owner => owner
    todo.recurrence_rules.first
  end

  context 'properties' do

    before :each do
      DataMapper::Model.raise_on_save_failure = false
    end

    it 'sets start_time to on create if start time is empty' do
      expect(model.start_time.to_i).to be_within(1).of Time.now.to_i
    end

    it 'doesn\'t set a start time if it\'s already set' do
      rule = Todo::Model::RecurrenceRule.create({:start_time => Time.gm('2000-01-01')})
      expect(rule.start_time).to eql Time.gm('2000-01-01')
    end

  end
end

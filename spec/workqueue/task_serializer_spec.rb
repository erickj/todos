require 'workqueue'

RSpec.describe WQ::TaskSerializer, :wq do

  let(:task) { WQ::Task.new }

  it 'provides a singleton getter' do
    expect(WQ::TaskSerializer.instance).to respond_to(:serialize, :deserialize)
  end

  it 'serializes a Task' do
    expect(WQ::TaskSerializer.instance.serialize(task)).to be_a(String)
  end

  it 'deserializes a Task' do
    serialized_task = WQ::TaskSerializer.instance.serialize(task)
    expect(WQ::TaskSerializer.instance.deserialize(serialized_task)).to be_eql(task)
  end
end

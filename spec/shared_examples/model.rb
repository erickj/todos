shared_examples 'a model' do

  let(:model) { described_class.new }

  it 'should have a created_at timestamp' do
    model.created_at = Time.now

    expect(model.created_at).to be_a Time
    expect(model.created_at).to be < Time.now
  end

end

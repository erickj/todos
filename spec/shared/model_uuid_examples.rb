require 'uuidtools'

shared_examples 'a UUID model' do

  context 'UUID properties' do
    it 'should have a UUID' do
      expect(subject.uuid).to be_a UUIDTools::UUID
    end
  end

  context 'UUID keys' do

    let(:klass) { subject.class }

    it 'should be indexed on uuid' do
      uuid_models = klass.all :uuid => subject.uuid
      expect(uuid_models.size).to be 1
      expect(uuid_models.first).to eql subject
    end

    it 'should be accessible via +by_uuid+' do
      uuid_model = klass.by_uuid subject.uuid
      expect(uuid_model).to eql subject
    end

    it 'should throw on +by_uuid!+ for missing models' do
      expect do
        klass.by_uuid! SecureRandom.uuid
      end.to raise_error(Regexp.new('^missing %s'%klass.name.split('::').last))
    end
  end

end

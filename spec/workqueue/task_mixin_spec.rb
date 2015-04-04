require 'uuidtools'
require 'workqueue'

RSpec.describe WQ::TaskMixin, :wq do

  let(:task) { WQ::Task.new }

  it 'is a task' do
    expect(task.is_task?).to be
  end

  it 'is of default type' do
    expect(task.task_type).to be :default
  end

  it 'is =~ equal to its type' do
    foo_task = WQ::Task.new(:foo)
    expect(foo_task =~ :foo).to be
  end

  it 'is =~ equal to itself' do
    foo_task = WQ::Task.new(:foo)
    expect(foo_task =~ foo_task).to be
  end

  it 'should have a UUID' do
    expect(UUIDTools::UUID.parse task.uuid).to be_a UUIDTools::UUID
  end

  context 'fields and build' do

    let(:field_values) do
      {
        :errand_list => [:bank, :shopping],
        :max_money => 100,
        :currency => :dollar,
        :done_by => Time.now + 3600
      }
    end

    class DoErrandsTask
      include WQ::TaskMixin

      field(:errand_list).default []
      field(:max_money).required.type Integer
      field(:currency).enum :dollar, :gbp, :chf
      field(:done_by).type(Time).validate do |time|
        raise 'I don\'t have a time machine' unless time > Time.now
      end
    end

    subject { DoErrandsTask.build field_values }

    it 'builds a task from a hash of fields' do
      expect(subject.errand_list).to eql [:bank, :shopping]
      expect(subject.max_money).to be 100
      expect(subject.done_by).to eql field_values[:done_by]
    end

    it 'builds a hash of the expected values with +to_h+' do
      expect(subject.to_h).to eql field_values
    end

    it 'uses default values for missing fields' do
      field_values.delete :errand_list
      subject = DoErrandsTask.build field_values
      expect(subject.errand_list).to eql []
    end

    it 'validates required fields' do
      field_values.delete :max_money
      expect { DoErrandsTask.build field_values }.to raise_error do |error|
        expect(error).to be_a WQ::TaskValidationError
        expect(error[:max_money].first).to be =~ /^missing required value/
      end
    end

    it 'validates expected types' do
      field_values[:max_money] = 10.1
      expect { DoErrandsTask.build field_values }.to raise_error do |error|
        expect(error).to be_a WQ::TaskValidationError
        expect(error[:max_money].first).to be =~ /^expected type/
      end
    end

    it 'validates custom validations' do
      field_values[:done_by] = Time.now - 3600
      expect { DoErrandsTask.build field_values }.to raise_error do |error|
        expect(error).to be_a WQ::TaskValidationError
        expect(error[:done_by].first).to be == 'I don\'t have a time machine'
      end
    end

    it 'validates enums' do
      field_values[:currency] = :canadian_dollar
      expect { DoErrandsTask.build field_values }.to raise_error do |error|
        expect(error).to be_a WQ::TaskValidationError
        expect(error[:currency].first).to be =~ /^invalid enum value/
      end
    end
  end
end

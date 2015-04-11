require 'todo/model'

RSpec.shared_examples 'a model task result hash' do

  context 'succeeds' do
    it 'should convert to task_result if it has a uuid' do
      task_result = Todo::Model.model_to_task_result_hash subject

      expect(task_result).to be  == {
        :uuid => subject.uuid.to_s,
        :class => subject.class
      }
    end

    it 'should convert from task_result if the class responds to by_uuid' do
      task_result = Todo::Model.model_to_task_result_hash subject

      model_from_task_result = Todo::Model.task_result_hash_to_model task_result

      expect(model_from_task_result).to be == subject
    end
  end

end

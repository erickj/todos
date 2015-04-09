module Todo
  module Model
    class CollaboratorAssignment
      include DataMapper::Resource

      belongs_to :todo_template, :key => true  # 'todo_template_id' is part of the CPK
      belongs_to :person, :key => true  # 'person_id' is part of the CPK
    end
  end
end

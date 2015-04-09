module Todo::Command
  module TaskType
    CREATE_TODO = :todo_create
    UPDATE_TODO = :todo_update
    DELETE_TODO = :todo_delete
    NOOP_TODO   = :todo_noop

    # Anonymous processor for NOOP_TODO
    Class.new do
      include Todo::Command::Processor
      processes NOOP_TODO
    end.new

    ENSURE_PERSON = :person_ensure
  end
end

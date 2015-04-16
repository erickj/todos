module Todo
  module View

    MESSAGES = {
      :create_todo => {
        :header => {
          :creator => 'Got your new Todo',
          :owner => '%s created a new Todo for you',
          :collaborator => '%s shared a new Todo with you'
        },
        :shared_with => 'Shared with %s people'
      }
    }

  end
end

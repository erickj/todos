module Todo
  module Model
    class Person
      include DataMapper::Resource

      property :id, Serial
      property :name, String
      property :email, String, :unique_index => true, :required => true
      property :created_at, EpochTime

      # See 'Customizing Associations':
      #   doc http://datamapper.org/docs/associations.html
      #   src https://github.com/datamapper/dm-core/blob/master/lib/dm-core/associations/relationship.rb
      has n, :todo_templates
    end
  end
end

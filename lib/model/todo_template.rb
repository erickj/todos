module Todo
  module Model
    class TodoTemplate
      include DataMapper::Resource

      property :id, Serial
      property :title, String
      property :description, Text
      property :created_at, EpochTime

      # See 'Customizing Associations':
      #   doc http://datamapper.org/docs/associations.html
      #   src https://github.com/datamapper/dm-core/blob/master/lib/dm-core/associations/relationship.rb
      belongs_to :owner, 'Person', :child_key => :owner_id
    end
  end
end

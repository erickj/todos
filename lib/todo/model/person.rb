require 'securerandom'

module Todo
  module Model
    class Person
      include DataMapper::Resource

      property :id, Serial
      property :uuid, UUID, :unique_index => true, :required => true
      property :name, String
      property :email, String, :unique_index => true, :required => true
      property :created_at, EpochTime

      # See 'Customizing Associations':
      #   doc http://datamapper.org/docs/associations.html
      #   src https://github.com/datamapper/dm-core/blob/master/lib/dm-core/associations/relationship.rb
      has n, :todo_templates, :child_key => :owner_id
      has n, :created_todos, 'TodoTemplate', :child_key => :creator_id

      before :valid?, :create_uuid

      def self.by_uuid(uuid)
        self.first :uuid => uuid
      end

      def self.by_uuid!(uuid)
        self.by_uuid(uuid) || raise('missing Person for uuid %s'%uuid)
      end

      def most_recent_todos(limit=10)
        limit = [limit, 50].min
        self.todo_templates.all(:limit => limit, :order => [ :created_at.desc ])
      end

      private
      def create_uuid
        self.uuid ||= SecureRandom.uuid
      end
    end
  end
end

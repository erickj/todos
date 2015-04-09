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

      before :valid?, :create_uuid

      def self.by_uuid(uuid)
        self.first :uuid => uuid
      end

      def self.by_uuid!(uuid)
        self.by_uuid(uuid) || raise('missing Person for uuid %s'%uuid)
      end

      private
      def create_uuid
        self.uuid ||= SecureRandom.uuid
      end
    end
  end
end

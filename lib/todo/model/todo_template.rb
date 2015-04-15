require 'securerandom'

module Todo
  module Model
    class TodoTemplate
      include DataMapper::Resource

      property :id, Serial
      property :uuid, UUID, :unique_index => true, :required => true
      property :slug, String, :unique_index => true, :required => true
      property :state, Enum[:todo, :done], :default => :todo, :index => true
      property :title, String
      property :description, Text
      property :created_at, EpochTime

      has n, :template_attachments
      has n, :recurrence_rules

      # See 'Customizing Associations':
      #   doc http://datamapper.org/docs/associations.html
      #   src https://github.com/datamapper/dm-core/blob/master/lib/dm-core/associations/relationship.rb
      belongs_to :owner, 'Person', :child_key => :owner_id
      belongs_to :creator, 'Person', :child_key => :creator_id

      # Many-to-many Relationships
      #   doc http://datamapper.org/docs/associations.html
      has n, :collaborator_assignments
      has n, :collaborators, 'Person', :through => :collaborator_assignments, :via => :person

      before :valid?, :create_uuid
      before :valid?, :create_slug
      before :valid?, :set_creator
      after :create, :create_recurrence_rule

      def self.by_uuid(uuid)
        self.first :uuid => uuid
      end

      def self.by_uuid!(uuid)
        self.by_uuid(uuid) || raise('missing TodoTemplate for uuid %s'%uuid)
      end

      private
      def create_uuid
        self.uuid ||= SecureRandom.uuid
      end

      def create_slug
        self.slug ||= SecureRandom.urlsafe_base64 10
      end

      def set_creator
        self.creator ||= self.owner
      end

      def create_recurrence_rule
        self.recurrence_rules << RecurrenceRule.create({
                                                         :todo_template => self,
                                                         :count => 1,
                                                         :start_time => Time.now
                                                       })
      end
    end
  end
end

require 'securerandom'

module Todo
  module Model
    class TodoTemplate
      include DataMapper::Resource

      property :id, Serial
      property :uuid, UUID, :unique_index => true, :required => true
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

      before :valid?, :create_uuid
      after :create, :create_recurrence_rule

      private
      def create_uuid
        self.uuid ||= SecureRandom.uuid
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

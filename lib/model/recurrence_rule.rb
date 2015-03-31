module Todo
  module Model
    class RecurrenceRule
      include DataMapper::Resource

      property :id, Serial

      # https://tools.ietf.org/html/rfc5545#section-3.3.10
      property :frequency, Enum[:secondly, :minutely, :hourly, :daily, :weekly, :monthly, :yearly]
      property :interval, Integer, :default => 1
      property :start_time, EpochTime, :index => true, :required => true
      property :end_time, EpochTime, :index => true
      property :count, Integer, :default => 1
      property :created_at, EpochTime

      belongs_to :todo_template

      before :valid?, :maybe_set_start_time

      private
      def maybe_set_start_time
        self.start_time ||= Time.now
      end
    end
  end
end

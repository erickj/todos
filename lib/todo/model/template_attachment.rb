module Todo
  module Model
    class TemplateAttachment
      include DataMapper::Resource

      CONTENT_LIMIT = 1 << 20 # 1MB

      property :id, Serial
      property :mime_type, String
      property :name, String
      property :content, Binary, :length => CONTENT_LIMIT, :lazy => true
      property :created_at, EpochTime

      belongs_to :todo_template
    end
  end
end

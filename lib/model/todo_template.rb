module Todo
  class Template
    include DataMapper::Resource

    property :id, Serial
    property :title, String
    property :body, Text
    property :owner, String
    property :created_at, EpochTime
  end
end

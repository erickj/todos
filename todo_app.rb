unless $LOAD_PATH.include? './lib'
  $LOAD_PATH.unshift './lib'
end

require 'data_mapper'
require 'json'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3:///' + ENV['RUN_DIR'] + '/todo.db');

# Todo requires
require 'api'
require 'mail_api'

module Todo; end

#DataMapper.auto_migrate!
DataMapper
  .finalize
  .auto_upgrade!

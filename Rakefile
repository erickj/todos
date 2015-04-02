begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

desc "Run RSpec tests with `bundle exec`"
task :bxspec do
  exec 'bundle exec rspec'
end
task :default => :bxspec

desc "Run the app in development mode"
task :run do
  # can't use shotgun until I fix TodoApp.start
#  puts 'Starting server with shotgun, this is for development only!'
#  exec 'bundle exec shotgun --server=thin --port=8000 config.ru'

  puts 'Starting server with `rackup config.ru`'
  exec 'rackup config.ru'
end

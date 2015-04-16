namespace :test do
  begin
    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new(:spec)
  rescue LoadError
  end

  desc 'Run rendering tests'
  task :render do
    exec 'bundle exec rspec --tag render'
  end
end
task :default => :'test:spec'

desc "Run the app in development mode"
task :run do
  # can't use shotgun until I fix TodoApp.start
  #  puts 'Starting server with shotgun, this is for development only!'
  #  exec 'bundle exec shotgun --server=thin --port=8000 config.ru'

  puts 'Starting server with `run.rb`'
  exec './run.rb'
end

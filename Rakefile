begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

desc "Run RSpec tests with `bundle exec`"
task :bxspec do
  puts 'Run with `bundle exec rspec` to see colorized output'
  puts `bundle exec rspec`
end

task :default => :bxspec

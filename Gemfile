# A sample Gemfile
source 'https://rubygems.org'

gem 'sinatra', '~>1.4.6'
gem 'data_mapper'
gem "em-hiredis"

group :development do
  gem 'shotgun'
end

group :test, :development do
  gem 'rspec'
  gem 'em-spec'
  gem 'dm-sqlite-adapter'
  gem 'database_cleaner'
end

group :production do
  gem 'dm-mysql-adapter'
end

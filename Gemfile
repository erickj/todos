# A sample Gemfile
source 'https://rubygems.org'

gem 'thin'
gem 'sinatra', '~>1.4.6'
gem 'data_mapper'
gem "em-hiredis"
gem "mandrill-api"

group :development do
  gem 'shotgun'
end

group :test, :development do
  gem 'rspec'
  gem 'em-spec'
  gem 'dm-sqlite-adapter'
  gem 'dm-transactions' # included manually due to database_cleaner
  gem 'database_cleaner'
end

group :production do
  gem 'dm-mysql-adapter'
end

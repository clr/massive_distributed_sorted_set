source :rubygems

gem 'rake', '~> 0.9.2'
gem 'sinatra'

# DB
gem 'riak-client', '~> 1.0.0'
gem 'ropl'

group :development, :test do
  # debugging
  gem 'linecache19', :git => 'git://github.com/mark-moseley/linecache'
  gem 'ruby-debug-base19x', '~> 0.11.30.pre4'
  gem "ruby-debug19", "0.11.6"
end

group :test do
  gem 'test-unit'
  gem 'rack-test'
  gem 'fakeweb', '~> 1.3'
end

group :development, :test do
  gem 'simplecov'
end


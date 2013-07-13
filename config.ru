$:.unshift(File.join(File.dirname(__FILE__), "app"))
ENV['BUNDLE_GEMFILE'] = File.join( File.expand_path(File.dirname(__FILE__)), "Gemfile" )
require 'rubygems'
require 'bundler'
Bundler.setup
require 'rack'
require 'json'
require 'rack/contrib'
require 'rack/contrib/not_found'
require 'rack/contrib/jsonp'
require 'rack/session/cookie'
require 'newrelic_rpm'
require 'newrelic_riak'

require 'exceptional'
use Rack::Exceptional, 'dd0783ce99bfd0d9799fcd5fe16763e31d4d58c2' if %w( prod ).include?(ENV['RACK_ENV'])

if ENV['RACK_ENV'] == 'test'
  # start Riak test server
  $:.unshift(File.join(File.dirname(__FILE__)))
  require 'test/support/ripple_test_server.rb'
end

require 'middleware'
require 'app'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => '0556222a6dfeaf094ed26d871ccd30a380dcf0ed9a47b517fb4a0ce4f5cac836d240f9563438a11b3fa6e35ca03631e4a0e5b95d15d8d982f09fdb685696679f'

# Set base_uri for API::Oauth::Server from config/oauth.yml
API::Oauth::Server.load_config(File.expand_path('../config/oauth.yml', __FILE__), [ENV['RACK_ENV']])

# OAuth server
use API::Oauth::Server
# Use xml
# use Rack::XML
# Use jsonp
use Rack::JSONP
# Present error messages without 500 status codes
use Att::RescueDocumentInvalid
# Create user if needed (move to OAuth middleware)
use MHealth::Middleware::CreateUser
use MHealth::Middleware::CreateApplication

# Save HIPAA audit logs
use MHealth::Middleware::HipaaAudit

# Mhealth
use API::V2::Application
use API::V2::Data
use API::V2::Product
use API::V2::Source
use API::V2::Unit
use API::V2::User
use API::V2::Ping

use API::V3::Application
use API::V3::Product
use API::V3::Subscription

DependencyDetection.detect!
NewRelic::Agent.after_fork(:force_reconnect => true)

if ENV['RACK_ENV'] == 'development'
  require 'resque/server'
  require 'new_relic/rack/developer_mode'
  use NewRelic::Rack::DeveloperMode
  run Rack::URLMap.new \
    "/" => ApiServer,
    "/resque" => Resque::Server.new
else
  run ApiServer
end

NewRelic::Agent.manual_start

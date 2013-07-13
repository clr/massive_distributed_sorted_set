$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'test/unit'
require 'fakeweb'
require 'net/http'
require 'riak'
require 'ropl'

require File.join('lib','persisted_object')
require File.join('lib','transaction_log')
require File.join('lib','manifest')
require File.join('lib','entry_set')

riak_config = YAML.load(File.read(File.expand_path(File.join('..','riak.yml'), __FILE__)))[:test]
riak_client = Riak::Client.new riak_config
ROPL        = Ropl::Ropl.new riak_client

riak_client.bucket("Manifest").props['n_val'] = 1
riak_client.bucket("EntrySet").props['n_val'] = 1
riak_client.bucket("EntrySet").props['pr'] = 1
riak_client.bucket("EntrySet").props['pw'] = 1

require File.expand_path('../helper', __FILE__)

class TestTransactionLog < Test::Unit::TestCase
  def setup
    @transaction_log = TransactionLog.new
  end

  def test_add_several_manifests_and_fetch_the_most_recent
    1000.times do |i|
      manifest_id = "manifestId#{i}"
      @transaction_log.append(manifest_id)
    end
    assert_equal 'manifestId999', @transaction_log.current_manifest
  end

  def clean_up_manifests_after_1000; end
end

require File.expand_path('../helper', __FILE__)

class TestTransactionLog < Test::Unit::TestCase
  def setup
    @transaction_log = TransactionLog.new
  end

  def test_fetch_the_most_recent_when_there_is_none
    assert @transaction_log.current_manifest(ROPL).is_a? Manifest
  end

  def test_add_some_scores_and_retrieve_them
    sample_size = 1000
    File.readlines(File.expand_path(File.join('..','fixtures',"primes.#{sample_size}.list"), __FILE__)).shuffle.each do |score|
      @transaction_log.add_score ROPL, score.to_i
    end
    assert_equal 1000, @transaction_log.manifests.length

    scores = [1299359, 1299349, 1299343, 1299341, 1299323, 1299317, 1299299, 1299289, 1299283, 1299269, 1299257, 1299227, 1299223, 1299211, 1299209]
    assert_equal scores, @transaction_log.current_manifest(ROPL).get_scores(ROPL, 30, 15)
  end
end

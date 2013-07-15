require File.expand_path('../helper', __FILE__)

class TestEverything < Test::Unit::TestCase
  def test_it_all
    # Set the sample size to 100, 1000, 10000, or 100000.
    sample_size = 1000

    # Create a transaction log.
    transaction_log = TransactionLog.new

    # Take these scores and randomly insert them into the transaction log.
    File.readlines(File.expand_path(File.join('..','fixtures',"primes.#{sample_size}.list"), __FILE__)).shuffle.each do |score|
      transaction_log.add_score ROPL, score.to_i
    end

    # Make sure we have the number of scores we think we should have.
    assert_equal sample_size, transaction_log.manifests.length

    # Get the known scores from the file, which is already in order.
    scores = File.readlines(File.expand_path(File.join('..','fixtures',"primes.#{sample_size}.list"), __FILE__)).reverse[30, 15].map(&:to_i)

    # Compare to the algorithms answer. Verification!
    assert_equal scores, transaction_log.current_manifest(ROPL).get_scores(ROPL, 30, 15)
  end
end

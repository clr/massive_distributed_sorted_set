require File.expand_path('../helper', __FILE__)

class TestManifestSet < Test::Unit::TestCase
  def setup
    @manifest = Manifest.new
  end

  def test_adding_one_entry
    @manifest.add_score ROPL, 7
    scores = @manifest.get_scores ROPL
    assert_equal [7], scores
  end

  def test_adding_one_hundred_entries
    sample_size = 100
    File.readlines(File.expand_path(File.join('..','fixtures',"primes.#{sample_size}.list"), __FILE__)).each do |score|
      @manifest.add_score ROPL, score.to_i
    end

    assert_equal 100, @manifest.total_entry_count

    scores = @manifest.get_scores ROPL, 18, 6
    assert_equal [1299541, 1299533, 1299499, 1299491, 1299457, 1299451], scores
  end

  def test_adding_entry_sets
    entry_set_A = EntrySet.new [0, 1, 2]
    entry_set_B = EntrySet.new [10, 11, 12]
    entry_set_C = EntrySet.new [20, 21, 22]
    key_A       = entry_set_A.save ROPL
    key_B       = entry_set_B.save ROPL
    key_C       = entry_set_C.save ROPL

    @manifest.add_entry_set key_A, entry_set_A
    @manifest.add_entry_set key_C, entry_set_C
    @manifest.add_entry_set key_B, entry_set_B

    assert_equal [20, 3, key_C], @manifest.entry_sets[0]
    assert_equal [10, 3, key_B], @manifest.entry_sets[1]
    assert_equal [0,  3, key_A], @manifest.entry_sets[2]
  end

  def test_handling_small_entry_sets
    entry_set_A = EntrySet.new [0, 1, 2]
    entry_set_B = EntrySet.new [10, 11, 12]
    entry_set_C = EntrySet.new [20, 21, 22]
    key_A       = entry_set_A.save ROPL
    key_B       = entry_set_B.save ROPL
    key_C       = entry_set_C.save ROPL
    @manifest.add_entry_set key_A, entry_set_A
    @manifest.add_entry_set key_B, entry_set_B
    @manifest.add_entry_set key_C, entry_set_C

    @manifest.farm_small_entry_sets! ROPL, 1, 2

    assert_equal 9, @manifest.total_entry_count
    assert_equal 2, @manifest.entry_sets.length
    assert_equal [20, 3, key_C], @manifest.entry_sets[0]
    assert_equal 0, @manifest.entry_sets[1][0]
    assert_equal 6, @manifest.entry_sets[1][1]

    @manifest.farm_small_entry_sets! ROPL, 0, 1

    assert_equal 9, @manifest.total_entry_count
    assert_equal 1, @manifest.entry_sets.length
    assert_equal 0, @manifest.entry_sets[0][0]
    assert_equal 9, @manifest.entry_sets[0][1]
  end

  def test_handling_large_entry_sets
    entry_set_A = EntrySet.new [0, 1, 2]
    entry_set_B = EntrySet.new [10, 11, 12]
    entry_set_C = EntrySet.new (2001..4000).to_a
    entry_set_D = EntrySet.new [5000, 5001, 5002]
    key_A       = entry_set_A.save ROPL
    key_B       = entry_set_B.save ROPL
    key_C       = entry_set_C.save ROPL
    key_D       = entry_set_D.save ROPL
    @manifest.add_entry_set key_A, entry_set_A
    @manifest.add_entry_set key_B, entry_set_B
    @manifest.add_entry_set key_C, entry_set_C
    @manifest.add_entry_set key_D, entry_set_D

    @manifest.farm_large_entry_sets! ROPL, 1

    assert_equal 2009, @manifest.total_entry_count
    assert_equal 5, @manifest.entry_sets.length
    assert_equal [5000, 3, key_D], @manifest.entry_sets[0]
    assert_equal 3001, @manifest.entry_sets[1][0]
    assert_equal 1000, @manifest.entry_sets[1][1]
    assert_equal 2001, @manifest.entry_sets[2][0]
    assert_equal 1000, @manifest.entry_sets[2][1]
    assert_equal [10,   3, key_B], @manifest.entry_sets[3]
    assert_equal [0,    3, key_A], @manifest.entry_sets[4]
  end

  def test_handling_entry_set_sizes
    entry_set_A = EntrySet.new [0, 1, 2]
    entry_set_B = EntrySet.new [10, 11, 12]
    entry_set_C = EntrySet.new (2001..4000).to_a
    entry_set_D = EntrySet.new [5000, 5001, 5002]
    key_A       = entry_set_A.save ROPL
    key_B       = entry_set_B.save ROPL
    key_C       = entry_set_C.save ROPL
    key_D       = entry_set_D.save ROPL
    @manifest.add_entry_set key_A, entry_set_A
    @manifest.add_entry_set key_B, entry_set_B
    @manifest.add_entry_set key_C, entry_set_C
    @manifest.add_entry_set key_D, entry_set_D

    @manifest.farm_entry_sets! ROPL

    assert_equal 2009, @manifest.total_entry_count
    assert_equal 3,    @manifest.entry_sets.length
    assert_equal 3003, @manifest.entry_sets[0][0]
    assert_equal 1001, @manifest.entry_sets[0][1]
    assert_equal 2001, @manifest.entry_sets[1][0]
    assert_equal 1002, @manifest.entry_sets[1][1]
    assert_equal 0,    @manifest.entry_sets[2][0]
    assert_equal 6,    @manifest.entry_sets[2][1]
  end

  def test_randomly_adding_one_hundred_thousand_entries
    sample_size = 1000
    File.readlines(File.expand_path(File.join('..','fixtures',"primes.#{sample_size}.list"), __FILE__)).shuffle.each do |score|
      @manifest.add_score ROPL, score.to_i
    end

    assert_equal sample_size, @manifest.total_entry_count

    # Get a random page.
    5.times do
      offset       = rand(sample_size)
      known_scores = File.readlines(File.expand_path(File.join('..','fixtures',"primes.#{sample_size}.list"), __FILE__)).reverse[offset, 20].map(&:to_i)
      scores       = @manifest.get_scores ROPL, offset, 20
      assert_equal known_scores, scores, "#{@manifest.inspect} offset:#{offset}"
    end
  end
end

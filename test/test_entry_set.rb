require File.expand_path('../helper', __FILE__)

class TestEntrySet < Test::Unit::TestCase
  def setup
    @entry_set = EntrySet.new
  end

  def test_add_several_entries_and_preserve_order
    # add entries
    1000.times do |i|
      entry = [rand(1000000), "player#{i}", "game#{rand(10000)}"]
      @entry_set.append(entry)
    end

    # confirm order
    previous = [1000001]
    1000.times do |i|
      assert previous[0] >= @entry_set.entries[i][0], "#{previous[0]} is not greater than or equal to #{@entry_set.entries[i][0]}."
      previous = @entry_set.entries[i]
    end
  end

  def test_bisect_new_entry_set
    1000.times do |i|
      @entry_set.append("entry_#{i}")
    end

    sibling_entry_sets = @entry_set.bisect

    assert_equal @entry_set.length, sibling_entry_sets[0].length + sibling_entry_sets[1].length
    assert_equal @entry_set.entries, sibling_entry_sets[0].entries + sibling_entry_sets[1].entries
  end

  def test_merge_entry_sets
    entry_set_A = EntrySet.new
    entry_set_B = EntrySet.new
    1000.times do |i|
      entry_set_A.append("entry_#{i}")
      entry_set_B.append("entry_#{i + 1000}")
    end

    @entry_set = entry_set_A.merge entry_set_B

    assert_equal 2000, @entry_set.length
  end

  def test_persist_entry_set
    1000.times do |i|
      @entry_set.append("entry_#{i}")
    end

    key        = @entry_set.save ROPL
    @entry_set = EntrySet.find ROPL, key

    assert_equal 1000, @entry_set.length, "Cannot find equivalent #{key}."
  end

  def clean_up_manifests_after_1000; end
end

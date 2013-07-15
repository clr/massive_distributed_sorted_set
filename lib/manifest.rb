# Keep a log of the current manifest file to use.  This record must
# only be written by a serialized process with read-you-write
# consistency enforced.  It can be read asynchronously.
#
# [
#   [es1_lowest_score, es1_legth, es1_key],
#   [es2_lowest_score, es2_legth, es2_key],
#   [es3_lowest_score, es3_legth, es3_key],
#   ...
#   [esN_lowest_score, esN_legth, esN_key]
# ]
#
class Manifest
  include PersistenceObject

  attr_accessor :entry_sets

  def initialize
    @entry_sets ||= []
  end

  def total_entry_count
    @entry_sets.map{|a| a[1]}.reduce(:+)
  end

  # Add an entry_set to the sorted manifest.
  def add_entry_set(entry_set_key, entry_set)
    @entry_sets << [entry_set.entries.last, entry_set.length, entry_set_key]
    @entry_sets.sort!.reverse!
  end

  # Add entries to the log.
  def add_score(ropl, entry)
    entry_set = EntrySet.new

    # Find the entry_set where this score belongs.
    if entry_set_index = @entry_sets.find_index{|es| entry > es[0]}
      entry_set  = EntrySet.find ropl, @entry_sets[entry_set_index][2]
      @entry_sets.delete_at entry_set_index
    end

    # Add score to entry_set.
    entry_set.append entry
    entry_set_key = entry_set.save ropl
    add_entry_set entry_set_key, entry_set

    # Examine entry_set sizes.
    # if < 500, try to merge
    # if > 1500 try to bisect
    farm_entry_sets! ropl
  end

  # Manage the entry_set sizes so that they don't
  # get too big or too small.
  def farm_entry_sets!(ropl)
    i = 0
    while @entry_sets[i] do
      if @entry_sets[i][1] < 500 && @entry_sets[i + 1]
        farm_small_entry_sets!(ropl, i, i + 1)
      elsif @entry_sets[i][1] > 1500
        farm_large_entry_sets!(ropl, i)
        i += 2
      else
        i += 1
      end
    end
  end

  # If entry_sets are too small, combine them.
  def farm_small_entry_sets!(ropl, i, j)
    entry_set_A  = EntrySet.find ropl, @entry_sets[i][2]
    entry_set_B  = EntrySet.find ropl, @entry_sets[j][2]
    entry_set    = entry_set_A.merge entry_set_B
    entry_set_id = entry_set.save ropl

    if j > i
      @entry_sets.delete_at(j)
      @entry_sets.delete_at(i)
    else
      @entry_sets.delete_at(i)
      @entry_sets.delete_at(j)
    end
    add_entry_set entry_set_id, entry_set
  end

  # If entry_sets are too big, break them up.
  def farm_large_entry_sets!(ropl, i)
    entry_set = EntrySet.find ropl, @entry_sets[i][2]
    entry_set_A, entry_set_B = entry_set.bisect
    entry_set_A_id = entry_set_A.save ropl
    entry_set_B_id = entry_set_B.save ropl

    @entry_sets.delete_at(i)
    add_entry_set entry_set_A_id, entry_set_A
    add_entry_set entry_set_B_id, entry_set_B
  end

  # Retrieve specific entries from an entry_set.
  def get_scores(ropl, offset = 0, limit = 10)
    # Find the entry_set we want to look in.
    entry_set_index = 0
    while offset > @entry_sets[entry_set_index][1]
      offset          -= @entry_sets[entry_set_index][1]
      entry_set_index += 1
    end

    # Fetch that entry_set and pull out the answer.
    entry_set  = EntrySet.find ropl, @entry_sets[entry_set_index][2]
    entry_set.entries[offset, limit]
  end
end

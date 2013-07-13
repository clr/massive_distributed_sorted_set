# Keep a log of the current manifest file to use.  This record must 
# only be written by a serialized process with read-you-write 
# consistency enforced.  It can be read asynchronously.
class EntrySet
  include PersistenceObject

  attr_accessor :entries

  def initialize(entries = [])
    @entries = entries.sort.reverse
  end

  def length
    @entries.length
  end

  # Add entries to the log.
  def append(entry)
    @entries << entry
    @entries.sort!.reverse!
  end

  # Bisect an entry set and return the new sibling.
  def bisect
    entry_set_A = self.class.new(@entries[0, (@entries.length / 2)])
    entry_set_B = self.class.new(@entries[(@entries.length / 2), @entries.length])
    [entry_set_A, entry_set_B]
  end

  # Merge two siblings into the first.
  def merge(entry_set)
    self.class.new((@entries + entry_set.entries).sort.reverse)
  end

  # Retrieve the most recent log.
  def current_manifest
    @manifests.last
  end
end

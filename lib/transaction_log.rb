# Keep a log of the current manifest file to use.  This record must
# only be written by a serialized process with read-you-write
# consistency enforced.  It can be read asynchronously.
#
# [
#   [m1_timestamp, m1_k],
#   [m2_timestamp, m2_k],
#   [m3_timestamp, m3_k],
#   ...
#   [mX_timestamp, mX_k]
# ]
#
class TransactionLog
  include PersistenceObject

  attr_accessor :manifests

  def initialize
    @manifests ||= []
  end

  # Add manifests to the log.
  def add_manifest(manifest_id)
    @manifests << [Time.now, manifest_id]
  end

  # Retrieve the most recent log.
  def current_manifest(ropl)
    return Manifest.new if @manifests.empty?
    Manifest.find ropl, @manifests.last[1]
  end

  # Add entries to the log.
  def add_score(ropl, entry)
    manifest = current_manifest ropl
    manifest.add_score ropl, entry
    manifest_id = manifest.save ropl
    add_manifest manifest_id
  end
end

# Keep a log of the current manifest file to use.  This record must 
# only be written by a serialized process with read-you-write 
# consistency enforced.  It can be read asynchronously.
class TransactionLog
  attr_accessor :manifests

  def initialize
    @manifests ||= []
  end

  # Add manifests to the log.
  def append(manifest_id)
    @manifests << manifest_id
  end

  # Retrieve the most recent log.
  def current_manifest
    @manifests.last
  end
end

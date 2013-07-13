# Keep a log of the current manifest file to use.  This record must 
module PersistenceObject
  class Error < StandardError; end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def save(ropl)
    robject = ropl.post self
    robject.key
  end

  module ClassMethods
    def find(ropl, id)
      ropl.get self, id
    end
  end
end

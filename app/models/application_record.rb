class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def hashid
    @hashid = HASHID.encode(id)
  end

  def self.find_by_hashid(hashid)
    find_by id: HASHID.decode(hashid)
  end
end

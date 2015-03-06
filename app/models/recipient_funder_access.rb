class RecipientFunderAccess < ActiveRecord::Base
  validates :funder_id, :recipient_id, :presence => true
end

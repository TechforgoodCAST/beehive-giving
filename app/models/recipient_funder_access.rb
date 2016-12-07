class RecipientFunderAccess < ActiveRecord::Base

  belongs_to :recipient, counter_cache: true

  validates :funder_id, :recipient_id, presence: true

end

class Request < ApplicationRecord
  belongs_to :recipient
  belongs_to :fund

  validates :recipient, :fund, presence: true
  validates :fund, uniqueness: { scope: :recipient,
                                     message: 'only one request per fund / recipient' }
end

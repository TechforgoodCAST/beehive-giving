class Assessment < ApplicationRecord
  belongs_to :fund
  belongs_to :proposal
  belongs_to :recipient
end

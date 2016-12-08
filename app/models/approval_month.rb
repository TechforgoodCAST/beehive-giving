class ApprovalMonth < ActiveRecord::Base
  has_and_belongs_to_many :funder_attributes
  validates :month, presence: true, uniqueness: true,
                    inclusion: { in: %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec) }
end

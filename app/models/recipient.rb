class Recipient < Organisation
  RECOMMENDATION_THRESHOLD = 1
  MAX_FREE_LIMIT = 3
  RECOMMENDATION_LIMIT = 6

  has_many :proposals
  has_many :funds, -> { distinct }, through: :proposals
  has_many :countries, -> { distinct }, through: :proposals
  has_many :districts, -> { distinct }, through: :proposals
  has_many :eligibilities, as: :category, dependent: :destroy
  accepts_nested_attributes_for :eligibilities

  has_many :grants # TODO: deprecated
  has_many :features, dependent: :destroy # TODO: deprecated
  has_many :recipient_funder_accesses # TODO: deprecated

  def subscribe!
    subscription.update(active: true)
  end

  def subscribed?
    subscription.active?
  end

  def transferred? # TODO: refactor
    proposals.where(state: 'transferred').count.positive?
  end

  def incomplete_first_proposal? # TODO: remove
    proposals.count == 1 && proposals.last.state != 'complete'
  end

  def recent_grants(year = 2015) # TODO: deprecated
    grants.where(
      'approved_on <= ? AND approved_on >= ?',
      "#{year}-12-31", "#{year}-01-01"
    )
  end
end

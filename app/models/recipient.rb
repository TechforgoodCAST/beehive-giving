class Recipient < Organisation
  has_many :proposals
  has_many :countries, -> { distinct }, through: :proposals
  has_many :districts, -> { distinct }, through: :proposals
  has_many :eligibilities, as: :category, dependent: :destroy
  accepts_nested_attributes_for :eligibilities

  has_many :features, dependent: :destroy # TODO: deprecated
  has_many :recipient_funder_accesses # TODO: deprecated

  def subscribe!
    subscription.update(active: true)
  end

  def subscribed?
    subscription.active?
  end

  def update_funds_checked!(eligibility)
    update_column :funds_checked, eligibility.count { |_, v| v.key? 'quiz' }
  end

  def transferred? # TODO: refactor
    proposals.where(state: 'transferred').count.positive?
  end

  def incomplete_first_proposal? # TODO: refactor
    proposals.count == 1 && proposals.last.state != 'complete'
  end
end

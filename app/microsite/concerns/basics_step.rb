class BasicsStep
  include ActiveModel::Model

  attr_accessor :funding_type, :total_costs, :org_type

  def funding_type=(str)
    @funding_type = str.blank? ? str : str.to_i
  end

  def org_type=(str)
    @org_type = str.blank? ? str : str.to_i
  end

  validates :funding_type, inclusion: { in: FUNDING_TYPES.pluck(1) }
  validates :org_type, inclusion: { in: (ORG_TYPES.pluck(1) - [-1]) }
  validates :total_costs, numericality: { greater_than_or_equal_to: 0 }

  def save
    if valid?
      # TODO: save_recipient!
      # TODO: save_proposal!
      true
    else
      false
    end
  end

  def transition
    # TODO: implement
  end

  private

    def save_recipient!
      # TODO: Save Recipient and set state
    end

    def save_proposal!
      # TODO: Save Proposal and set state
    end
end

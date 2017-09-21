class BasicsStep
  include ActiveModel::Model

  attr_reader :assessment
  attr_accessor :funder_id, :funding_type, :total_costs, :org_type,
                :charity_number, :company_number

  def funding_type=(str)
    @funding_type = str.blank? ? str : str.to_i
  end

  def org_type=(str)
    @org_type = str.blank? ? str : str.to_i
  end

  validates :funding_type, inclusion: { in: FUNDING_TYPES.pluck(1) }
  validates :org_type, inclusion: { in: (ORG_TYPES.pluck(1) - [-1]) }
  validates :total_costs, numericality: { greater_than: 0 }
  validates :charity_number, presence: {
    if: -> { [1, 3].include? org_type }
  }
  validates :company_number, presence: {
    if: -> { [2, 3, 5].include? org_type }
  }

  def save
    if valid?
      create_assessment if save_recipient! && save_proposal!
    else
      false
    end
  end

  private

    def load_recipient
      @recipient = Recipient.new(
        charity_number: @charity_number,
        company_number: @company_number,
        org_type: @org_type
      )
      @recipient.scrape_org
      @recipient = @recipient.find_with_reg_nos || @recipient
    end

    def save_recipient!
      load_recipient
      return true if @recipient.persisted?
      @recipient.set_slug
      @recipient.save(validate: false)
    end

    def save_proposal!
      Proposal.skip_callback(:save, :after, :initial_recommendation)
      @proposal = @recipient.proposals.where(
        state: 'basics',
        funding_type: @funding_type,
        total_costs: @total_costs
      ).first_or_initialize
      @proposal.save(validate: false)
      Proposal.set_callback(:save, :after, :initial_recommendation)
    end

    def create_assessment
      @assessment = Assessment.where(
        funder_id: @funder_id,
        recipient: @recipient,
        proposal: @proposal
      ).first_or_initialize
      @assessment.state = 'eligibility'
      @assessment.save
    end
end

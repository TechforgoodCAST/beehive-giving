class Proposal < ActiveRecord::Base

  after_validation :trigger_clear_beneficiary_ids
  before_save :save_all_age_groups_if_all_ages
  before_save :build_proposal_recommendation
  after_save :save_districts_from_countries

  belongs_to :recipient
  has_and_belongs_to_many :beneficiaries
  has_and_belongs_to_many :age_groups
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts

  TYPE_OF_SUPPORT = ['Only financial', 'Mostly financial', 'Equal financial and non-financial', 'Mostly non-financial', 'Only non-financial']
  GENDERS = ['All genders', 'Female', 'Male', 'Transgender', 'Other']
  FUNDING_TYPE = [
    'Revenue funding - running costs, salaries and activity costs',
    'Capital funding - purchase and refurbishment of equipment, and buildings',
    'Other', "Don't know"
  ]
  AFFECT_GEO = [
    ['One or more local areas', 0],
    ['One or more regions', 1],
    ['An entire country', 2],
    ['Across many countries', 3]
  ]

  include Workflow
  workflow_column :state
  workflow do
    state :initial do
      event :next_step, :transitions_to => :registered
    end
    state :registered do
      event :next_step, :transitions_to => :complete
    end
    state :complete
  end

  # Requirements
  validates :recipient, :funding_duration, presence: true,
              if: ('self.initial? || self.complete?')
  validates :type_of_support, inclusion: { in: TYPE_OF_SUPPORT, message: 'please select an option' },
              if: ('self.initial? || self.complete?')
  validates :funding_type, inclusion: { in: FUNDING_TYPE, message: 'please select an option' },
              if: ('self.initial? || self.complete?')
  validates :funding_duration, numericality: { only_integer: true, greater_than_or_equal_to: 1 },
              if: ('self.initial? || self.complete?')
  validates :total_costs, numericality: { greater_than_or_equal_to: 0, message: 'please enter the amount of funding you are seeking' },
              # format: { with: /\A\d+\.?\d{0,2}\z/, message: 'only two decimal places allowed' },
              if: ('self.initial? || self.complete?')
  validates :total_costs_estimated, inclusion: { message: 'please select an option', in: [true, false] },
              if: ('self.initial? || self.complete?')
  validates :all_funding_required, inclusion: { message: 'please select an option', in: [true, false] },
              if: ('self.initial? || self.complete?')

  # Beneficiaries
  validates :affect_people, presence: { message: 'you must affect either people or other groups' },
              if: ('self.initial? || self.complete?'), unless: 'self.affect_other?'
  validates :affect_other, presence: { message: 'you must affect either people or other groups' },
              if: ('self.initial? || self.complete?'), unless: 'self.affect_people?'
  validates :affect_people, :affect_other, inclusion: { in: [true, false], message: 'please select an option' },
              if: ('self.initial? || self.complete?')
  validates :gender, :age_groups,
              presence: { message: 'Please select an option' },
              if: ('self.affect_people? && self.initial? || self.complete?'),
              unless: '!self.affect_people? && self.affect_other?'
  validates :gender, inclusion: { in: GENDERS, message: 'please select an option'},
              if: ('self.affect_people? && self.initial? || self.complete?'),
              unless: '!self.affect_people? && self.affect_other?'
  validate :beneficiaries_people, :beneficiaries_other_group,
              if: ('self.initial? || self.complete?')
  validates :beneficiaries_other,
              presence: { message: "please uncheck 'Other' or specify details" },
              if: :beneficiaries_other_required

  def beneficiaries_people
    if (beneficiary_ids & Beneficiary.where(category: 'People').pluck(:id)).count < 1
      errors.add(:beneficiaries, 'Please select an option') if affect_people?
    end
  end

  def beneficiaries_other_group
    if (beneficiary_ids & Beneficiary.where(category: 'Other').pluck(:id)).count < 1
      unless beneficiaries_other_required?
        errors.add(:beneficiaries, 'Please select an option') if affect_other?
      end
    end
  end

  # Location
  validates :affect_geo, inclusion: { in: 0..3, message: 'please select an option'},
              if: ('self.initial? || self.complete?')
  validates :countries, presence: true
  validates :districts, presence: true,
              if: ('self.initial? || self.complete?'),
              unless: Proc.new { |o| o.affect_geo > 1 if o.affect_geo.present? }
                
  def build_proposal_recommendation
    self.recipient.refined_recommendation if self.recipient.recommendations.pluck(:funder_id).uniq.count < Funder.active.count
    Funder.active.each do |funder|
      recommendation = load_recommendation(funder)
      recommendation.update_attribute(:grant_amount_recommendation, calculate_grant_amount_recommendation(funder))
      recommendation.update_attribute(:grant_duration_recommendation, calculate_grant_duration_recommendation(funder))
    end
  end

  private

  def save_all_age_groups_if_all_ages
    if self.age_group_ids.include?(AgeGroup.first.id)
      self.age_group_ids = AgeGroup.pluck(:id)
    end
  end

  def clear_beneficiary_ids(category)
    self.beneficiary_ids = self.beneficiary_ids - Beneficiary.where(category: category).pluck(:id)
  end

  def trigger_clear_beneficiary_ids
    clear_beneficiary_ids('People') unless self.affect_people?
    clear_beneficiary_ids('Other') unless self.affect_other?
  end

  def save_districts_from_countries
    # refactor into background job too slow
    district_ids_array = []
    if self.affect_geo > 1
      self.countries.each do |country|
        district_ids_array += District.where(country_id: country.id).pluck(:id)
      end
    end
    self.district_ids = district_ids_array
  end

  def load_recommendation(funder)
    Recommendation.where(recipient: recipient, funder: funder).first
  end

  def proposal_recommendation(funder, group, request, precision)
    score = 0
    total_grants = funder.recent_grants(funder.current_attribute.year).count
    funder.recent_grants(funder.current_attribute.year).group(group).count.each do |k, v|
      score += (v.to_f / total_grants) if (k-precision..k+precision).include?(request)
    end
    score
  end

  def calculate_grant_amount_recommendation(funder)
    proposal_recommendation(funder, 'amount_awarded', total_costs, 5000)
  end

  def calculate_grant_duration_recommendation(funder)
    if funder.recent_grants(funder.current_attribute.year).where('days_from_start_to_end is NULL').count == 0
      proposal_recommendation(funder, 'days_from_start_to_end', (funding_duration * 30), 28)
    else
      0
    end
  end

end

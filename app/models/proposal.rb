class Proposal < ActiveRecord::Base

  after_validation :trigger_clear_beneficiary_ids
  after_validation :check_affect_geo
  before_save :save_all_age_groups_if_all_ages
  after_save :save_districts_from_countries
  after_save :initial_recommendation

  belongs_to :recipient
  has_and_belongs_to_many :beneficiaries
  has_and_belongs_to_many :age_groups
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :implementations

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
    state :transferred do
      event :next_step, :transitions_to => :registered
    end
    state :registered do
      event :next_step, :transitions_to => :complete
    end
    state :complete
  end

  validate :prevent_second_proposal_until_first_is_complete, if: 'self.initial?'

  # Requirements
  validates :recipient, :funding_duration, presence: true
  validates :type_of_support, inclusion: { in: TYPE_OF_SUPPORT, message: 'please select an option' }
  validates :funding_type, inclusion: { in: FUNDING_TYPE, message: 'please select an option' }
  validates :funding_duration, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :total_costs, numericality: { greater_than_or_equal_to: 0, message: 'please enter the amount of funding you are seeking' }
              # format: { with: /\A\d+\.?\d{0,2}\z/, message: 'only two decimal places allowed' }
  validates :total_costs_estimated, inclusion: { message: 'please select an option', in: [true, false] }
  validates :all_funding_required, inclusion: { message: 'please select an option', in: [true, false] }

  # Beneficiaries
  validates :affect_people, presence: { message: 'you must affect either people or other groups' }, unless: 'self.affect_other?'
  validates :affect_other, presence: { message: 'you must affect either people or other groups' }, unless: 'self.affect_people?'
  validates :affect_people, :affect_other, inclusion: { in: [true, false], message: 'please select an option' }
  validates :gender, :age_groups,
              presence: { message: 'Please select an option' },
              unless: '!self.affect_people? && self.affect_other?'
  validates :gender, inclusion: { in: GENDERS, message: 'please select an option'},
              unless: '!self.affect_people? && self.affect_other?'
  validate :beneficiaries_people, :beneficiaries_other_group
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
  validates :affect_geo, inclusion: { in: 0..3, message: 'please select an option'}
  validates :countries, presence: true
  validates :districts, presence: true,
              unless: Proc.new { |o| o.affect_geo > 1 if o.affect_geo.present? }

  # Privacy
  validates :private, inclusion: { in: [true, false], message: 'please select an option' }

  # Registered
  validates :title, uniqueness: { scope: :recipient_id, message: 'each proposal must have a unique title' },
              if: ('self.registered? || self.complete?')
  validates :title, :tagline, :outcome1, presence: true, length: { maximum: 280, message: 'please use 280 characters or less' },
              if: ('self.registered? || self.complete?')
  validates :implementations, presence: true,
              unless: :implementations_other_required,
              if: ('self.registered? || self.complete?')
  validates :implementations_other,
              presence: { message: "please uncheck 'Other' or specify details" },
              if: :implementations_other_required

  def initial_recommendation
    Funder.active.each do |funder|
      if funder.attributes.any? && self.present?
        beneficiary_score = 0
        beneficiary_score += compare_arrays('beneficiaries', funder)
        beneficiary_score += compare_arrays('age_groups', funder) # refactor, bias?

        # refactor
        # Age
        org_type_score = 0
        if funder.current_attribute.funded_age_temp
          funder_age_temp = funder.current_attribute.funded_age_temp
          result = nil
          if funder_age_temp < 365
            result = 0
          elsif funder_age_temp >= 365 && funder_age_temp < 1095
            result = 1
          elsif funder_age_temp >=1095 && funder_age_temp < 26
            result = 2
          elsif funder_age_temp >= 1460
            result = 3
          end
          org_type_score += 1 if self.recipient.operating_for == result
        end

        # refactor
        # Income
        if funder.current_attribute.funded_income_temp
          funder_income_temp = funder.current_attribute.funded_income_temp
          result = nil
          if funder_income_temp < 10000
            result = 0
          elsif funder_income_temp >= 10000 && funder_income_temp < 100000
            result = 1
          elsif funder_income_temp >= 100000 && funder_income_temp < 1000000
            result = 2
          elsif funder_income_temp >= 1000000 && funder_income_temp < 10000000
            result = 3
          elsif funder_income_temp >= 100000000
            result = 4
          end
          org_type_score += 1 if self.recipient.income == result
        end

        location_score = 0
        location_score += compare_arrays('countries', funder)
        location_score += compare_arrays('districts', funder) # refactor, this will bias towards funders with district data

        # unless self.transferred?
        grant_amount_recommendation = calculate_grant_amount_recommendation(funder)
        grant_duration_recommendation = calculate_grant_duration_recommendation(funder)
        # end

        score = beneficiary_score +
                org_type_score +
                location_score

        # Reset for closed funders, refactor
        score = 0 if Funder::CLOSED_FUNDERS.include?(funder.name)
      end

      scores = {
        score: score,
        org_type_score: org_type_score,
        beneficiary_score: beneficiary_score,
        location_score: location_score,
        grant_amount_recommendation: grant_amount_recommendation,
        grant_duration_recommendation: grant_duration_recommendation
      }

      save_recommendation(funder, scores)
    end
  end

  def check_affect_geo
    unless self.affect_geo == 2
      if self.country_ids.uniq.count > 1
        self.affect_geo = 3
      elsif (self.district_ids & Country.find(self.country_ids[0]).districts.pluck(:id)).count == Country.find(self.country_ids[0]).districts.count
        self.affect_geo = 2
      elsif District.where(id: district_ids).pluck(:region).uniq.count > 1
        self.affect_geo = 1
      else
        self.affect_geo = 0
      end
    end
  end

  private

  def load_recommendation(funder)
    Recommendation.where(recipient: recipient, funder: funder).first
  end

  def save_recommendation(funder, scores)
    r = Recommendation.where(
      recipient: self.recipient,
      funder: funder
    ).first_or_initialize
    r.update_attributes(scores)
    # refactor update columns might be quicker
  end

  def compare_arrays(array, funder)
    comparison = (self.send(array).pluck(:id) & funder.send(array).pluck(:id).uniq).count.to_f
    return comparison > 0 && funder.send(array).count > 0 ? comparison / self.send(array).count.to_f : 0
  end

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
    self.beneficiaries_other_required = false unless self.affect_other?
  end

  def save_districts_from_countries
    # refactor into background job too slow
    if self.affect_geo > 1
      district_ids_array = []
      self.countries.each do |country|
        district_ids_array += District.where(country_id: country.id).pluck(:id)
      end
      self.district_ids = district_ids_array.uniq
    end
  end

  def prevent_second_proposal_until_first_is_complete
    if self.recipient.proposals.count == 1 && self.recipient.proposals.where(state: 'complete').count < 1
      errors.add(:proposal, 'Please complete your first proposal before creating a second.')
    end
  end

  def funding_request_recommendation(funder, group, request, precision)
    score = 0
    total_grants = funder.recent_grants(funder.current_attribute.year).count
    funder.recent_grants(funder.current_attribute.year).group(group).count.each do |k, v|
      score += (v.to_f / total_grants) if (k-precision..k+precision).include?(request)
    end
    score
  end

  def calculate_grant_amount_recommendation(funder)
    funding_request_recommendation(funder, 'amount_awarded', total_costs, 5000)
  end

  def calculate_grant_duration_recommendation(funder)
    if funder.recent_grants(funder.current_attribute.year).where('days_from_start_to_end is NULL').count == 0
      funding_request_recommendation(funder, 'days_from_start_to_end', (funding_duration * 30), 28)
    else
      0
    end
  end

end

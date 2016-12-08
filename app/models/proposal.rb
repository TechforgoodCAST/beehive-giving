class Proposal < ActiveRecord::Base
  after_validation :trigger_clear_beneficiary_ids
  after_validation :check_affect_geo
  before_save :save_all_age_groups_if_all_ages
  after_save :save_districts_from_countries
  after_save :initial_recommendation

  has_many :recommendations, dependent: :destroy
  has_many :funds, through: :recommendations

  belongs_to :recipient
  has_many :enquiries, dependent: :destroy
  has_and_belongs_to_many :beneficiaries
  has_and_belongs_to_many :age_groups
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :implementations

  TYPE_OF_SUPPORT = ['Only financial', 'Mostly financial', 'Equal financial and non-financial', 'Mostly non-financial', 'Only non-financial'].freeze
  GENDERS = ['All genders', 'Female', 'Male', 'Transgender', 'Other'].freeze
  FUNDING_TYPE = [
    'Revenue funding - running costs, salaries and activity costs',
    'Capital funding - purchase and refurbishment of equipment, and buildings',
    'Other', "Don't know"
  ].freeze
  AFFECT_GEO = [
    ['One or more local areas', 0],
    ['One or more regions', 1],
    ['An entire country', 2],
    ['Across many countries', 3]
  ].freeze

  include Workflow
  workflow_column :state
  workflow do
    state :initial do
      event :next_step, transitions_to: :registered
    end
    state :transferred do
      event :next_step, transitions_to: :registered
    end
    state :registered do
      event :next_step, transitions_to: :complete
    end
    state :complete
  end

  validate :prevent_second_proposal_until_first_is_complete, if: 'self.initial?', on: :create

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
  validates :gender, inclusion: { in: GENDERS, message: 'please select an option' },
              unless: '!self.affect_people? && self.affect_other?'
  validate :beneficiaries_people, :beneficiaries_other_group
  validates :beneficiaries_other,
              presence: { message: "please uncheck 'Other' or specify details" },
              if: :beneficiaries_other_required

  def beneficiaries_people
    return unless beneficiaries_not_selected('People')
    errors.add(:beneficiaries, 'Please select an option') if affect_people?
  end

  def beneficiaries_other_group
    return unless beneficiaries_not_selected('Other') && beneficiaries_other_required?
    errors.add(:beneficiaries, 'Please select an option') if affect_other?
  end

  # Location
  validates :affect_geo, inclusion: { in: 0..3, message: 'please select an option' }
  validates :countries, presence: true
  validates :districts, presence: true,
              if: proc { |o| o.affect_geo.present? && o.affect_geo < 2 } # TODO: test

  # Privacy
  validates :private, inclusion: { in: [true, false], message: 'please select an option' }

  # Registered
  validates :title, uniqueness: { scope: :recipient_id, message: 'each proposal must have a unique title' },
              if: 'self.registered? || self.complete?'
  validates :title, :tagline, :outcome1, presence: true, length: { maximum: 280, message: 'please use 280 characters or less' },
              if: 'self.registered? || self.complete?'
  validates :implementations, presence: true,
              unless: :implementations_other_required,
              if: 'self.registered? || self.complete?'
  validates :implementations_other,
              presence: { message: "please uncheck 'Other' or specify details" },
              if: :implementations_other_required

  def initial_recommendation
    beehive_insight = call_beehive_insight(
      ENV['BEEHIVE_INSIGHT_ENDPOINT'],
      beneficiaries_request
    )
    beehive_insight_amounts = call_beehive_insight(
      ENV['BEEHIVE_INSIGHT_AMOUNTS_ENDPOINT'],
      { amount: total_costs }
    )
    beehive_insight_durations = call_beehive_insight(
      ENV['BEEHIVE_INSIGHT_DURATIONS_ENDPOINT'],
      { duration: funding_duration }
    )

    Fund.all.find_each do |fund|
      org_type_score = beneficiary_score = location_score = amount_score = duration_score = 0

      amount_score = fund_request_scores(fund, beehive_insight_amounts, amount_score)

      if fund.open_data?

        # org type recommendation
        if fund.org_type_distribution?
          org_type_score = parse_distribution(
            fund.org_type_distribution,
            Organisation::ORG_TYPE[recipient.org_type + 1][0]
          )
        end

        if org_type_score.positive?
          [
            [Organisation::OPERATING_FOR, 'operating_for'],
            [Organisation::INCOME, 'income'],
            [Organisation::EMPLOYEES, 'employees'],
            [Organisation::EMPLOYEES, 'volunteers']
          ].each do |i|
            org_type_score += parse_distribution(
              fund.send("#{i[1]}_distribution"),
              i[0][recipient[i[1]]][0]
            )
          end
        end

        # beneficiary recommendation
        if gender? && fund.gender_distribution?
          beneficiary_score = parse_distribution(
            fund.gender_distribution,
            gender
          )
        else
          beneficiary_score = 0
        end
        # TODO: add age_groups

        if beehive_insight.key?(fund.slug)
          beneficiary_score += beehive_insight[fund.slug]
        else
          beneficiary_score = 0
        end

        # amount requested recommendation
        amount_score = 0 if fund.amount_max_limited? && total_costs > fund.amount_max

        # duration requested recommendation
        duration_score = fund_request_scores(fund, beehive_insight_durations, duration_score)
        duration_score = 0 if fund.duration_months_max_limited? && funding_duration > fund.duration_months_max
      end

      # location recommendation
      location_score += compare_arrays('countries', fund) # TODO: refactor
      location_score += compare_arrays('districts', fund) # TODO: refactor

      score = org_type_score +
              beneficiary_score +
              location_score +
              amount_score +
              duration_score

      scores = {
        org_type_score: org_type_score,
        beneficiary_score: beneficiary_score,
        location_score: location_score,
        grant_amount_recommendation: amount_score,
        grant_duration_recommendation: duration_score,
        score: score
      }
      save_recommendation(fund, scores)
    end
  end

  def refine_recommendations
    return if Fund.active.count == funds.count
    initial_recommendation
    recommendations.where(fund_id: Fund.inactive_ids).destroy_all
  end

  def show_fund(fund)
    recipient.subscribed? ||
      recipient.recommended_fund?(fund) ||
      recommendation(fund).eligibility?
  end

  def check_affect_geo
    # TODO: refactor
    return if affect_geo.blank? || affect_geo == 2
    if country_ids.uniq.count > 1
      self.affect_geo = 3
    elsif (district_ids & Country.find(country_ids[0]).districts.pluck(:id)).count == Country.find(country_ids[0]).districts.count
      self.affect_geo = 2
    elsif District.where(id: district_ids).pluck(:region).uniq.count > 1
      self.affect_geo = 1
    else
      self.affect_geo = 0
    end
  end

  def recommendation(fund)
    Recommendation.find_by(proposal: self, fund: fund)
  end

  def eligible?(fund)
    recommendation(fund).eligibility == 'Eligible'
  end

  private

    def beneficiaries_not_selected(category)
      (beneficiary_ids & Beneficiary.where(category: category).pluck(:id)).count < 1
    end

    def parse_distribution(data, comparison)
      data.sort_by { |i| i['position'] }
          .select { |i| i['label'] == comparison unless i['label'] == 'Unknown' }
          .first['percent']
    end

    def beneficiaries_request
      request = {}
      Beneficiary::BENEFICIARIES.map do |hash|
        if beneficiaries.pluck(:sort).include?(hash[:sort])
          request[hash[:sort]] = 1
        else
          request[hash[:sort]] = 0
        end
      end
      request
    end

    def call_beehive_insight(endpoint, data)
      options = {
        body: { data: data }.to_json,
        basic_auth: { username: ENV['BEEHIVE_INSIGHT_TOKEN'], password: ENV['BEEHIVE_INSIGHT_SECRET'] },
        headers: { 'Content-Type' => 'application/json' }
      }
      resp = HTTParty.post(endpoint, options)
      JSON.parse(resp.body).to_h
    end

    def fund_request_scores(fund, data, score)
      score = 0
      data.each do |k, v|
        score += v if fund.slug == k
      end
      score
    end

    def save_recommendation(fund, scores)
      r = Recommendation.where(
        proposal: self,
        fund: fund
      ).first_or_create
      r.update_attributes(scores)
    end

    def compare_arrays(array, fund) # TODO: refactor
      comparison = (send(array).pluck(:id) & fund.send(array).pluck(:id).uniq).count.to_f
      comparison.positive? && fund.send(array).count.positive? ? comparison / send(array).count.to_f : 0
    end

    def save_all_age_groups_if_all_ages
      return unless age_group_ids.include?(AgeGroup.first.id)
      self.age_group_ids = AgeGroup.pluck(:id)
    end

    def clear_beneficiary_ids(category)
      self.beneficiary_ids = beneficiary_ids - Beneficiary.where(category: category).pluck(:id)
    end

    def trigger_clear_beneficiary_ids
      clear_beneficiary_ids('People') unless affect_people?
      clear_beneficiary_ids('Other') unless affect_other?
      self.beneficiaries_other_required = false unless affect_other?
    end

    def save_districts_from_countries
      # TODO: refactor into background job too slow
      return unless affect_geo > 1
      district_ids_array = []
      countries.each do |country|
        district_ids_array += District.where(country_id: country.id).pluck(:id)
      end
      self.district_ids = district_ids_array.uniq
    end

    def prevent_second_proposal_until_first_is_complete
      return unless recipient.proposals.count == 1 && recipient.proposals.where(state: 'complete').count < 1
      errors.add(:proposal, 'Please complete your first proposal before creating a second.')
    end
end

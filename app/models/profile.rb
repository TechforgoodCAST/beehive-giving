# TODO: deprecated
class Profile < ActiveRecord::Base
  before_save :clear_other_options, :save_all_age_groups_if_all_ages
  before_validation :set_year_to_current_year

  belongs_to :organisation

  has_and_belongs_to_many :beneficiaries
  has_and_belongs_to_many :implementations
  has_and_belongs_to_many :implementors
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :age_groups

  VALID_YEARS = ((Time.zone.today.year - 3)..(Time.zone.today.year))
                .to_a.reverse
  GENDERS = ['All genders', 'Female', 'Male', 'Transgender', 'Other'].freeze

  include Workflow
  workflow_column :state
  workflow do
    state :beneficiaries do
      event :next_step, transitions_to: :location
    end
    state :location do
      event :next_step, transitions_to: :team
    end
    state :team do
      event :next_step, transitions_to: :work
    end
    state :work do
      event :next_step, transitions_to: :finance
    end
    state :finance do
      event :next_step, transitions_to: :complete
    end
    state :complete
  end

  ## beneficiaries state validations

  validates :affect_people, presence: { message: 'you must affect either people or other groups' }, if: 'self.beneficiaries? || self.complete?', unless: 'self.affect_other?'

  validates :affect_other, presence: { message: 'you must affect either people or other groups' }, if: 'self.beneficiaries? || self.complete?', unless: 'self.affect_people?'

  validates :affect_people, :affect_other, inclusion: { in: [true, false], message: 'please select an option' }, if: 'self.beneficiaries? || self.complete?'

  validates :organisation, :year,
            presence: true, if: 'self.beneficiaries? || self.complete?'

  validates :year, uniqueness: { scope: :organisation_id,
                                 message: 'only one is allowed per year', if: 'self.beneficiaries? || self.complete?' }

  validates :year, inclusion: { in: VALID_YEARS }, if: 'self.beneficiaries? || self.complete?'

  validates :gender, :age_groups,
            presence: { message: 'Please select an option' }, if: 'self.affect_people? && self.beneficiaries? || self.complete?', unless: '!self.affect_people? && self.affect_other?'

  validates :gender, inclusion: { in: GENDERS, message: 'please select an option' }, if: 'self.affect_people? && self.beneficiaries? || self.complete?', unless: '!self.affect_people? && self.affect_other?'

  validate :beneficiaries_people, :beneficiaries_other_categories, if: 'self.beneficiaries? || self.complete?'

  def beneficiaries_people
    return unless (beneficiary_ids & Beneficiary.where(category: 'People').pluck(:id)).count < 1
    errors.add(:beneficiaries, 'Please select an option') if affect_people?
  end

  def beneficiaries_other_categories
    return unless (beneficiary_ids & Beneficiary.where(category: 'Other').pluck(:id)).count < 1 && beneficiaries_other_required?
    errors.add(:beneficiaries, 'Please select an option') if affect_other?
  end

  validates :beneficiaries_other, presence: { message: "please uncheck 'Other' or specify details" }, if: :beneficiaries_other_required

  ## location state validations

  validates :countries, :districts, presence: true, if: 'self.location? || self.complete?'

  ## team state validations

  validates :staff_count, :volunteer_count, :trustee_count,
            presence: true, if: 'self.team? || self.complete?'

  validates :implementors, presence: true, if: 'self.team? || self.complete?', unless: 'self.implementors_other.present?'

  validates :implementors_other, presence: { message: "must uncheck 'Other' or specify details" }, if: :implementors_other_required

  validates :staff_count, :volunteer_count, :trustee_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            if: 'self.team? || self.complete?' }

  ## work state validations

  validates :implementations, presence: true, if: 'self.work? || self.complete?', unless: 'self.implementations_other.present?'

  validates :implementations_other, presence: { message: "must uncheck 'Other' or specify details" }, if: :implementations_other_required

  validates :does_sell, inclusion: { message: 'please select an option', in: [true, false] }, if: 'self.work? || self.complete?'

  validates :income, :expenditure, presence: true, if: 'self.finance? || self.complete?'

  validates :income, :expenditure,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            if: 'self.finance? || self.complete?' }

  def clear_other_options
    self.beneficiaries_other = nil unless beneficiaries_other_required?
    self.implementors_other = nil unless implementors_other_required?
    self.implementations_other = nil unless implementations_other_required?
  end

  def set_year_to_current_year
    self.year = Time.zone.today.year unless year.present?
  end

  def save_all_age_groups_if_all_ages
    return unless age_group_ids.include?(AgeGroup.first.id)
    self.age_group_ids = AgeGroup.pluck(:id)
  end
end

# TODO: deprecated
class Profile < ApplicationRecord
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

  validates :affect_people, presence: { message: 'you must affect either people or other groups' }, if: proc { beneficiaries? || complete? }, unless: proc { affect_other? }

  validates :affect_other, presence: { message: 'you must affect either people or other groups' }, if: proc { beneficiaries? || complete? }, unless: proc { affect_people? }

  validates :affect_people, :affect_other, inclusion: { in: [true, false], message: 'please select an option' }, if: proc { beneficiaries? || complete? }

  validates :organisation, :year,
            presence: true, if: proc { beneficiaries? || complete? }

  validates :year, uniqueness: { scope: :organisation_id,
                                 message: 'only one is allowed per year', if: proc { beneficiaries? || complete? } }

  validates :year, inclusion: { in: VALID_YEARS }, if: proc { beneficiaries? || complete? }

  validates :gender, :age_groups,
            presence: { message: 'Please select an option' }, if: proc { affect_people? && beneficiaries? || complete? }, unless: proc { !affect_people? && affect_other? }

  validates :gender, inclusion: { in: GENDERS, message: 'please select an option' }, if: proc { affect_people? && beneficiaries? || complete? }, unless: proc { !affect_people? && affect_other? }

  validate :beneficiaries_people, :beneficiaries_other_categories, if: proc { beneficiaries? || complete? }

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

  validates :countries, :districts, presence: true, if: proc { location? || complete? }

  ## team state validations

  validates :staff_count, :volunteer_count, :trustee_count,
            presence: true, if: proc { team? || complete? }

  validates :implementors, presence: true, if: proc { team? || complete? }, unless: proc { implementors_other.present? }

  validates :implementors_other, presence: { message: "must uncheck 'Other' or specify details" }, if: :implementors_other_required

  validates :staff_count, :volunteer_count, :trustee_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            if: proc { team? || complete? } }

  ## work state validations

  validates :implementations, presence: true, if: proc { work? || complete? }, unless: proc { implementations_other.present? }

  validates :implementations_other, presence: { message: "must uncheck 'Other' or specify details" }, if: :implementations_other_required

  validates :does_sell, inclusion: { message: 'please select an option', in: [true, false] }, if: proc { work? || complete? }

  validates :income, :expenditure, presence: true, if: proc { finance? || complete? }

  validates :income, :expenditure,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            if: proc { finance? || complete? } }

  def clear_other_options
    self.beneficiaries_other = nil unless beneficiaries_other_required?
    self.implementors_other = nil unless implementors_other_required?
    self.implementations_other = nil unless implementations_other_required?
  end

  def set_year_to_current_year
    self.year = Time.zone.today.year if year.blank?
  end

  def save_all_age_groups_if_all_ages
    return unless age_group_ids.include?(AgeGroup.first.id)
    self.age_group_ids = AgeGroup.pluck(:id)
  end
end

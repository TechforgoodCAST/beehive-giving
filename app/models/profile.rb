class Profile < ActiveRecord::Base
  belongs_to :organisation

  has_and_belongs_to_many :beneficiaries
  has_and_belongs_to_many :implementations
  has_and_belongs_to_many :implementors
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts

  VALID_YEARS = ((Date.today.year-3)..(Date.today.year)).to_a.reverse
  GENDERS = ['All genders', 'Female', 'Male', 'Transgender', 'Other']

  validates :organisation, :countries, :districts, :beneficiaries,
            :implementations, :implementors, presence: true

  validates :year, :gender,
            :min_age, :max_age, :income, :expenditure, :volunteer_count,
            :staff_count, :beneficiaries_count, presence: true
  validates :income, :expenditure, :volunteer_count, :staff_count, :beneficiaries_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :min_age, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: :max_age,
    message: 'min. age must be less than max. age' }
  validates :max_age, numericality: { greater_than_or_equal_to: :min_age,
    message: 'max. age must be greater than min.age' }

  # refactor
  # validates :volunteer_count, numericality: { greater_than: :staff_count,
  #   message: 'must have at least one volunteer if no staff' }, unless: :staff_count?
  # validates :staff_count, numericality: { greater_than: :volunteer_count,
  #   message: 'must have at least one member of staff if no volunteers' }, unless: :volunteer_count?

  validates :year, uniqueness: {scope: :organisation_id, message: 'only one is allowed per year'}

  validates :gender, inclusion: {in: GENDERS}
  validates :year, inclusion: {in: VALID_YEARS}
  validates :beneficiaries_count_actual, :income_actual, :expenditure_actual,
            :does_sell, inclusion: {in: [true, false]}
end

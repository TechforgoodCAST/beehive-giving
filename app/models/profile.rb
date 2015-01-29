class Profile < ActiveRecord::Base
  belongs_to :organisation

  has_and_belongs_to_many :beneficiaries
  has_and_belongs_to_many :implementations
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :markets

  VALID_YEARS = ((Date.today.year-5)..(Date.today.year)).to_a.reverse
  GENDERS = ['All genders', 'Only female', 'Only male', 'Only other genders']
  CURRENCY = ['GBP (£)', 'EUR (€)', 'USD ($)']
  GOODS_SERVICES = %w[Goods Services Both]

  validates :organisation, :districts, :beneficiaries, :implementations, :markets, presence: true

  validates :year, :gender, :currency, :goods_services,
            :min_age, :max_age, :income, :expenditure, :volunteer_count,
            :staff_count, :job_role_count, :department_count, :goods_count,
            :services_count, presence: true
  validates :income, :expenditure, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :min_age, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: :max_age,
    message: 'min. age must be less than max. age' }
  validates :max_age, numericality: { greater_than_or_equal_to: :min_age,
    message: 'max. age must be greater than min.age' }

  validates :volunteer_count, numericality: { greater_than: :staff_count,
    message: 'must have at least one volunteer if no staff' }, unless: :staff_count?
  validates :staff_count, numericality: { greater_than: :volunteer_count,
    message: 'must have at least one member of staff if no volunteers' }, unless: :volunteer_count?

  validates :job_role_count, :department_count, numericality: { greater_than: 0, message: 'must be at least one'}

  validates :services_count, numericality: { greater_than: :goods_count,
    message: 'must provide at least one service if no goods' }, unless: :goods_count?
  validates :goods_count, numericality: { greater_than: :services_count,
    message: 'must provide at least one item of goods if no services' }, unless: :services_count?

  validates :year, uniqueness: {scope: :organisation_id, message: 'only one is allowed per year'}

  validates :gender, inclusion: {in: GENDERS}
  validates :year, inclusion: {in: VALID_YEARS}
  validates :currency, inclusion: {in: CURRENCY}
  validates :goods_services, inclusion: {in: GOODS_SERVICES}

end

class Profile < ActiveRecord::Base
  belongs_to :organisation

  has_and_belongs_to_many :beneficiaries
  has_and_belongs_to_many :implementations
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :markets

  VALID_YEARS = ((Date.today.year-5)..(Date.today.year)).to_a.reverse
  GENDERS = ['All genders', 'Only female', 'Only male']
  CURRENCY = ['GBP (£)', 'EUR (€)', 'USD ($)']
  GOODS_SERVICES = %w[Goods Services Both]
  WHO_PAYS = ['No, we get income from donations, or grants', 'Goods', 'Services', 'Both']

  validates :organisation, presence: true

  validates :year, :gender, :currency, :goods_services, :who_pays,
            :min_age, :max_age, :income, :expenditure, :volunteer_count,
            :staff_count, :job_role_count, :department_count, :goods_count,
            :services_count, presence: true
  validates :min_age, :max_age, :income, :expenditure, :volunteer_count,
            :staff_count, :job_role_count, :department_count, :goods_count,
            :services_count, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  validates :year, uniqueness: {scope: :organisation_id, message: 'only one is allowed per year'}

  validates :gender, inclusion: {in: GENDERS}
  validates :year, inclusion: {in: VALID_YEARS}
  validates :currency, inclusion: {in: CURRENCY}
  validates :goods_services, inclusion: {in: GOODS_SERVICES}
  validates :who_pays, inclusion: {in: WHO_PAYS}

end

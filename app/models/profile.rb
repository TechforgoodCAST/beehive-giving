class Profile < ActiveRecord::Base
  belongs_to :organisation

  VALID_YEARS = ((Date.today.year-5)..(Date.today.year)).to_a.reverse
  GENDERS = %w(male female both)

  validates :organisation, presence: true
  validates :year, :gender, :currency, :goods_services, :who_pays, :who_buys,
            :min_age, :max_age, :income, :expenditure, :volunteer_count,
            :staff_count, :job_role_count, :department_count, :goods_count,
            :units_count, :services_count, :beneficiaries_count, :beneficiaries, presence: true
  validates :min_age, :max_age, :income, :expenditure, :volunteer_count,
            :staff_count, :job_role_count, :department_count, :goods_count,
            :units_count, :services_count, :beneficiaries_count,
            numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :year, uniqueness: {scope: :organisation_id, message: 'only one is allowed per year'}
  validates :gender, inclusion: {in: GENDERS}
  validates :year, inclusion: {in: VALID_YEARS}

  has_and_belongs_to_many :beneficiaries

end

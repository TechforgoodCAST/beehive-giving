class Profile < ActiveRecord::Base
  before_validation :allowed_years, unless: Proc.new { |profile| profile.year.nil? }

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

  validates :year, :gender, :min_age, :max_age, :income, :expenditure,
            :volunteer_count, :staff_count, :trustee_count, :beneficiaries_count,
            presence: true

  validates :min_age, :max_age, :volunteer_count, :staff_count, :trustee_count,
            :income, :expenditure, :beneficiaries_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :min_age, numericality: { less_than_or_equal_to: :max_age,
            message: 'minimum age must be less than maximum age',
            unless: Proc.new { |profile| profile.min_age.nil? || profile.max_age.nil? } }
  validates :max_age, numericality: { greater_than_or_equal_to: :min_age || 0,
            message: 'maximum age must be greater than minimum age',
            unless: Proc.new { |profile| profile.min_age.nil? || profile.max_age.nil? } }

  validates :volunteer_count, numericality: { greater_than: 0,
            message: 'must have at least one volunteer if no staff',
            if: Proc.new { |profile| profile.staff_count.nil? || profile.staff_count == 0 } }
  validates :staff_count, numericality: { greater_than: 0,
            message: 'must have at least one member of staff if no volunteers',
            if: Proc.new { |profile| profile.volunteer_count.nil? || profile.volunteer_count == 0 } }

  validates :year, uniqueness: {scope: :organisation_id, message: 'only one is allowed per year'}

  validates :gender, inclusion: {in: GENDERS}
  validates :year, inclusion: {in: VALID_YEARS}

  def allowed_years
    if organisation.founded_on
      if organisation.founded_on.year.to_i > year
        errors.add(:year, "you can't make a profile before #{organisation.founded_on.year} because that's when your organisation was founded")
      end
    end
  end

end

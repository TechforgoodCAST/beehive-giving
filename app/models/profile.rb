class Profile < ActiveRecord::Base

  before_validation :allowed_years, unless: Proc.new { |profile| profile.year.nil? }
  before_save :clear_other_options

  belongs_to :organisation

  has_and_belongs_to_many :beneficiaries
  has_and_belongs_to_many :implementations
  has_and_belongs_to_many :implementors
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts

  VALID_YEARS = ((Date.today.year-3)..(Date.today.year)).to_a.reverse
  GENDERS = ['All genders', 'Female', 'Male', 'Transgender', 'Other']

  include Workflow
  workflow_column :state
  workflow do
    state :beneficiaries do
      event :next_step, :transitions_to => :location
    end
    state :location do
      event :next_step, :transitions_to => :team
    end
    state :team do
      event :next_step, :transitions_to => :work
    end
    state :work do
      event :next_step, :transitions_to => :finance
    end
    state :finance do
      event :next_step, :transitions_to => :complete
    end
    state :complete
  end

  ## beneficiaries state validations

  validates :year, uniqueness: { scope: :organisation_id,
            message: 'only one is allowed per year', if: ('self.beneficiaries? || self.complete?') }

  validates :year, inclusion: { in: VALID_YEARS }, if: ('self.beneficiaries? || self.complete?')

  validates :gender, inclusion: { in: GENDERS }, if: ('self.beneficiaries? || self.complete?')

  validates :organisation, :year, :gender, :min_age, :max_age,
            presence: true, if: ('self.beneficiaries? || self.complete?')

  validates :beneficiaries, presence: true, if: ('self.beneficiaries? || self.complete?'), unless: 'self.beneficiaries_other.present?'

  # validates :beneficiaries_other_required, presence: true, unless: 'self.beneficiaries.present?'

  validates :beneficiaries_other, presence: true, if: :beneficiaries_other_required

  validates :min_age, :max_age, numericality: { only_integer: true,
            greater_than_or_equal_to: 0, if: ('self.beneficiaries? || self.complete?') }

  validates :min_age, numericality: { less_than_or_equal_to: :max_age,
            message: 'minimum age must be less than maximum age',
            unless: Proc.new { |profile| profile.min_age.nil? || profile.max_age.nil? },
            if: ('self.beneficiaries? || self.complete?') }

  validates :max_age, numericality: { greater_than_or_equal_to: :min_age || 0,
            message: 'maximum age must be greater than minimum age',
            unless: Proc.new { |profile| profile.min_age.nil? || profile.max_age.nil? },
            if: ('self.beneficiaries? || self.complete?') }

  ## location state validations

  validates :countries, :districts, presence: true, if: ('self.location? || self.complete?')

  ## team state validations

  validates :staff_count, :volunteer_count, :trustee_count,
            presence: true, if: ('self.team? || self.complete?')

  validates :implementors, presence: true, if: ('self.team? || self.complete?'), unless: 'self.implementors_other.present?'

  validates :implementors_other, presence: true, if: :implementors_other_required

  validates :staff_count, :volunteer_count, :trustee_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
            if: ('self.team? || self.complete?') }

  validates :volunteer_count, numericality: { greater_than: 0,
            message: 'must have at least one volunteer if no staff',
            unless: Proc.new { |profile| (profile.staff_count.nil? || profile.staff_count != 0) },
            if: ('self.team? || self.complete?') }

  validates :staff_count, numericality: { greater_than: 0,
            message: 'must have at least one member of staff if no volunteers',
            unless: Proc.new { |profile| (profile.volunteer_count.nil? || profile.volunteer_count != 0) },
            if: ('self.team? || self.complete?') }

  ## work state validations

  validates :beneficiaries_count, presence: true,
            if: ('self.work? || self.complete?')

  validates :implementations, presence: true, if: ('self.work? || self.complete?'), unless: 'self.implementations_other.present?'

  validates :implementations_other, presence: true, if: :implementations_other_required

  validates :does_sell, inclusion: { in: [true, false] }, if: ('self.work? || self.complete?')

  validates :beneficiaries_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
            if: ('self.work? || self.complete?') }

  ## finance state validations

  validates :income, :expenditure, presence: true, if: ('self.finance? || self.complete?')

  validates :income, :expenditure,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
            if: ('self.finance? || self.complete?') }

  def allowed_years
    if organisation.founded_on
      if organisation.founded_on.year.to_i > year
        errors.add(:year, "you can't make a profile before #{organisation.founded_on.year} because that's when your organisation was founded")
      end
    end
  end

  def clear_other_options
    unless self.beneficiaries_other_required?
      self.beneficiaries_other = nil
    end
    unless self.implementors_other_required?
      self.implementors_other = nil
    end
    unless self.implementations_other_required?
      self.implementations_other = nil
    end
  end

end

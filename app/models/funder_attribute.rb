class FunderAttribute < ActiveRecord::Base
  before_validation       :grant_count_from_grants, :approval_months_from_grants, :funding_type_from_grants,
                          :funding_size_and_duration_from_grants, :funded_organisation_age,
                          :funded_organisation_income_and_staff

  belongs_to              :funder
  has_and_belongs_to_many :application_supports
  has_and_belongs_to_many :reporting_requirements

  belongs_to              :funding_stream
  has_and_belongs_to_many :funding_types
  has_and_belongs_to_many :approval_months

  VALID_YEARS = ((Date.today.year-3)..(Date.today.year)).to_a.reverse
  NON_FINANCIAL_SUPPORT = ['None', 'A little', 'A lot']

  validates :funder_id, presence: true
  # validates :grant_count, :application_count, :enquiry_count, numericality: { allow_blank: true, only_integer: true, greater_than_or_equal_to: 0 }
  # validates :year, uniqueness: {scope: :funder_id, message: 'only one is allowed per year'}

  def grant_count_from_grants
    if self.funder && self.funder.grants.count > 0
      self.grant_count = funder.grants.where('approved_on > ?', Date.today - 365).count
    end
  end

  def approval_months_from_grants
    if self.funder && self.approval_months.empty?
      self.funder.grants.where('approved_on > ?', Date.today - 365).pluck(:approved_on).uniq.each do |d|
        self.approval_months << ApprovalMonth.find_by_month(d.strftime("%b"))
      end
    end
  end

  def funding_type_from_grants
    if self.funder && self.funding_types.empty?
      self.funder.grants.where('approved_on > ?', Date.today - 365).pluck(:grant_type).uniq.each do |t|
        self.funding_types << FundingType.find_by_label(t)
      end
    end
  end

  def funding_size_and_duration_from_grants
    if self.funder
      self.funding_size_average = self.funder.grants.where('approved_on > ?', Date.today - 365).calculate(:average, :amount_awarded) if self.funding_size_average.nil?
      self.funding_size_min = self.funder.grants.where('approved_on > ?', Date.today - 365).calculate(:minimum, :amount_awarded) if self.funding_size_min.nil?
      self.funding_size_max = self.funder.grants.where('approved_on > ?', Date.today - 365).calculate(:maximum, :amount_awarded) if self.funding_size_max.nil?

      self.funding_duration_average = self.funder.grants.where('approved_on > ?', Date.today - 365).calculate(:average, :days_from_start_to_end) if self.funding_duration_average.nil?
      self.funding_duration_min = self.funder.grants.where('approved_on > ?', Date.today - 365).calculate(:minimum, :days_from_start_to_end) if self.funding_duration_min.nil?
      self.funding_duration_max = self.funder.grants.where('approved_on > ?', Date.today - 365).calculate(:maximum, :days_from_start_to_end) if self.funding_duration_max.nil?
    end
  end

  def funded_organisation_age
    if self.funder && self.funder.grants.count != 0
      count = 0
      sum = 0.0
      self.funder.recipients.where('approved_on > ?', Date.today - 365).pluck(:founded_on).uniq.each do |d|
        count += 1
        sum += (Date.today - d) unless d.nil?
      end
      self.funded_average_age = (sum / count).round(1) if self.funded_average_age.nil?
    end
  end

  def funded_organisation_income_and_staff
    if self.funder && self.funder.grants.count != 0
      unless self.funder.profiles.count < self.funder.grants.count
        self.funded_average_income = self.funder.profiles.where('approved_on > ?', Date.today - 365).calculate(:average, :income) if self.funded_average_income.nil?
        self.funded_average_paid_staff = self.funder.profiles.where('approved_on > ?', Date.today - 365).calculate(:average, :staff_count) if self.funded_average_paid_staff.nil?
      end
    end
  end

  # enum application_process: [:open, :invite_only]
  # enum funding_type: [:unrestricted, :loan, :social_finance, :core_costs, :project_costs]

  # def funding_frequency_label
  #   funding_round_frequency == 0 ? "Continous" :
  #   funding_round_frequency == 1 ? "every month" :
  #   "every #{funding_round_frequency} months"
  # end

  # def self.application_process_options_for_select
  #   application_processes.map { |k,v| [k.humanize,v] }
  # end

  # def self.funding_type_options_for_select
  #   funding_types.map { |k,v| [k.humanize, v] }
  # end

end

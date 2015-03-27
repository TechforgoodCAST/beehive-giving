class FunderAttribute < ActiveRecord::Base
  before_save :grant_count

  belongs_to :funder

  has_and_belongs_to_many :application_processes
  has_and_belongs_to_many :application_supports
  has_and_belongs_to_many :reporting_requirements

  VALID_YEARS = ((Date.today.year-3)..(Date.today.year)).to_a.reverse
  NON_FINANCIAL_SUPPORT = ['None', 'A little', 'A lot']

  validates :funder_id, :year, :grant_count, :non_financial_support,
  :application_processes, :application_supports, :reporting_requirements, presence: true
  validates :grant_count, :application_count, :enquiry_count, numericality: { allow_blank: true, only_integer: true, greater_than_or_equal_to: 0 }
  validates :year, uniqueness: true

  def grant_count
    self.grant_count = self.funder.grants.where("extract(year FROM approved_on) = ?", self.year).count if self.funder
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

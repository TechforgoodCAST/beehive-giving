class FunderAttributes < ActiveRecord::Base
  belongs_to :funder

  enum application_process: [:open, :invite_only]
  enum funding_type: [:unrestricted, :loan, :social_finance, :core_costs, :project_costs]

  def funding_frequency_label
    funding_round_frequency == 0 ? "Continous" :
    funding_round_frequency == 1 ? "every month" :
    "every #{funding_round_frequency} months"
  end

  def self.application_process_options_for_select
    application_processes.map { |k,v| [k.humanize,v] }
  end

  def self.funding_type_options_for_select
    funding_types.map { |k,v| [k.humanize, v] }
  end

end

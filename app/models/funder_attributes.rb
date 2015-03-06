class FunderAttributes < ActiveRecord::Base
  belongs_to :funder

  enum application_process: [:open, :invite_only]
  enum funding_type: [:unrestricted, :loan, :social_finance, :core_costs, :project_costs]

  def funding_frequency_label
    funding_round_frequency == 0 ? "Continous" :
    funding_round_frequency == 1 ? "every month" :
    "every #{funding_round_frequency} months"
  end


end

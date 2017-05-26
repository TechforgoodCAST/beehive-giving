class RemoveUnusedFundFields < ActiveRecord::Migration[5.0]
  def change
    [
      :amount_known, :amount_min_limited, :amount_max_limited, :amount_min,
      :amount_max, :amount_notes, :duration_months_known,
      :duration_months_min_limited, :duration_months_max_limited,
      :duration_months_min, :duration_months_max, :duration_months_notes,
      :decision_in_months, :match_funding_restrictions, :payment_procedure,
      :accepts_calls_known, :accepts_calls, :contact_number, :contact_email,
      :recipient_count, :amount_awarded_sum, :amount_awarded_mean,
      :amount_awarded_median, :amount_awarded_min, :amount_awarded_max,
      :duration_awarded_months_mean, :duration_awarded_months_median,
      :duration_awarded_months_min, :duration_awarded_months_max,
      :duration_awarded_months_distribution, :operating_for_distribution,
      :employees_distribution, :volunteers_distribution, :gender_distribution,
      :age_group_distribution, :beneficiary_distribution,
      :geographic_scale_distribution, :district_distribution
    ].each do |field|
      remove_column :funds, field
    end
  end
end

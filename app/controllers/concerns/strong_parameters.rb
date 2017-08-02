module StrongParameters
  extend ActiveSupport::Concern

  def user_params
    params.require(:user)
          .permit(:first_name, :last_name, :job_role, :email, :password,
                  :password_confirmation, :role, :agree_to_terms, :org_type,
                  :charity_number, :company_number)
  end

  def recipient_params
    params.require(:recipient)
          .permit(:name, :website, :street_address, :country, :charity_number,
                  :company_number, :operating_for, :multi_national, :income,
                  :employees, :volunteers, :org_type, organisation_ids: [])
  end

  def proposal_params
    params.require(:proposal).permit(
      :type_of_support, :funding_duration, :funding_type, :total_costs,
      :total_costs_estimated, :all_funding_required, :affect_people,
      :affect_other, :gender, :beneficiaries_other,
      :beneficiaries_other_required, :affect_geo, :title, :tagline, :private,
      :outcome1, :outcome2, :outcome3, :outcome4, :outcome5,
      :implementations_other_required, :implementations_other,
      age_group_ids: [], beneficiary_ids: [], country_ids: [],
      district_ids: [], implementation_ids: [], theme_ids: []
    )
  end

  def feedback_params
    params.require(:feedback)
          .permit(:suitable, :most_useful, :nps, :taken_away,
                  :informs_decision, :other, :application_frequency,
                  :grant_frequency, :marketing_frequency)
  end
end

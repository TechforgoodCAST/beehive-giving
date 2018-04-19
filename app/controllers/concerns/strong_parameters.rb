module StrongParameters
  extend ActiveSupport::Concern

  def user_params
    params.require(:user)
          .permit(:first_name, :last_name, :email, :password,
                  :password_confirmation, :role, :agree_to_terms, :org_type,
                  :charity_number, :company_number)
  end

  def recipient_params
    params.require(:recipient)
          .permit(:name, :website, :street_address, :country, :charity_number,
                  :company_number, :operating_for, :multi_national, :income_band,
                  :employees, :volunteers, :org_type, organisation_ids: [])
  end

  def feedback_params
    params.require(:feedback)
          .permit(:suitable, :most_useful, :nps, :taken_away,
                  :informs_decision, :other, :application_frequency,
                  :grant_frequency, :marketing_frequency)
  end
end

ActiveAdmin.register Fund do
  permit_params :funder_id, :type_of_fund, :name, :description, :open_call,
                :active, :currency, :application_link, :key_criteria,
                :match_funding_restrictions, :payment_procedure,
                :restrictions_known, :skip_beehive_data, :open_data,
                :period_start, :period_end, :grant_count,
                :amount_awarded_distribution, :award_month_distribution,
                :country_distribution, :geographic_scale,
                :geographic_scale_limited, country_ids: [], district_ids: [],
                                           restriction_ids: []

  controller do
    def find_resource
      Fund.find_by(slug: params[:id])
    end
  end

  index do
    selectable_column
    column 'Funder' do |fund|
      link_to fund.funder.name, [:admin, fund.funder]
    end
    column :name
    actions
  end

  filter :updated_at

  show do
    attributes_table do
      row :slug
      row :funder do |fund|
        link_to fund.funder.name, [:admin, fund.funder]
      end
      row :name
      row :type_of_fund
      row :name
      row :description
      row :open_call
      row :active
      row :currency
      row :application_link
      row :key_criteria
      # row :match_funding_restrictions
      # row :payment_procedure
      row :restrictions_known
      row :restrictions do |fund|
        fund.restrictions.each do |r|
          li r.details
        end
      end
      if fund.open_data
        row :open_data
        row :period_start
        row :period_end
        row :grant_count
        # row :recipient_count
        # row :amount_awarded_sum
        # row :amount_awarded_mean
        # row :amount_awarded_median
        # row :amount_awarded_min
        # row :amount_awarded_max
        row :amount_awarded_distribution
        # row :duration_awarded_months_mean
        # row :duration_awarded_months_median
        # row :duration_awarded_months_min
        # row :duration_awarded_months_max
        # row :duration_awarded_months_distribution
        row :award_month_distribution
        # row :org_type_distribution
        # row :operating_for_distribution
        # row :income_distribution
        # row :employees_distribution
        # row :volunteers_distribution
        # row :gender_distribution
        # row :age_group_distribution
        # row :beneficiary_distribution
        # row :geographic_scale_distribution
        row :country_distribution
        # row :district_distribution
      end
    end
  end

  form do |f|
    f.inputs do
      inputs 'Basics' do
        f.input :funder, input_html: { class: 'chosen-select' }
        f.input :type_of_fund, input_html: { value: 'Grant' }
        f.input :name
        f.input :description
        f.input :open_call
        f.input :active
        f.input :currency, input_html: { value: 'GBP' }
        f.input :application_link
        f.input :key_criteria
        # f.input :match_funding_restrictions
        # f.input :payment_procedure
      end

      inputs 'Restrictions' do
        f.input :restrictions_known
        f.input :restrictions, collection: Restriction.all, member_label: :details,
                               input_html: { multiple: true, class: 'chosen-select' }
      end

      # inputs 'Amounts' do
      #   f.input :amount_known
      #     f.input :amount_min_limited
      #       f.input :amount_min
      #     f.input :amount_max_limited
      #       f.input :amount_max
      #   f.input :amount_notes
      # end

      # inputs 'Durations' do
      #   f.input :duration_months_known
      #     f.input :duration_months_min_limited
      #       f.input :duration_months_min
      #     f.input :duration_months_max_limited
      #       f.input :duration_months_max
      #   f.input :duration_months_notes
      # end

      # f.input :decision_in_months

      # inputs 'Deadlines' do
      #   f.input :deadlines_known
      #   f.input :deadlines_limited
      #   f.inputs do
      #     f.has_many :deadlines, heading: false, allow_destroy: true do |d|
      #       d.input :deadline
      #     end
      #   end
      # end

      # inputs 'Stages' do
      #   f.input :stages_known
      #   f.input :stages_count
      #   f.inputs do
      #     f.has_many :stages, heading: false, allow_destroy: true do |s|
      #       s.input :name, as: :select, collection: Stage::STAGES
      #       s.input :position
      #       s.input :feedback_provided
      #       s.input :link
      #     end
      #   end
      # end

      # inputs 'Contact' do
      #   f.input :accepts_calls_known
      #     f.input :accepts_calls
      #       f.input :contact_number
      #   f.input :contact_email
      # end
      #
      inputs 'Geography' do
        f.input :geographic_scale, as: :select, collection: Proposal::AFFECT_GEO
        f.input :geographic_scale_limited
        f.input :countries, collection: Country.all, member_label: :name,
                            input_html: { multiple: true, class: 'chosen-select' }
        f.input :districts, collection: District.all, member_label: :label,
                            input_html: { multiple: true, class: 'chosen-select' }
      end

      # f.input :restrictions_known # boolean
      #
      # f.input :outcomes_known # boolean
      #
      # f.input :documents_known # boolean
      #
      # f.input :decision_makers_known # boolean

      inputs 'Open Data' do
        f.input :skip_beehive_data, as: :boolean
        f.input :open_data
        f.input :period_start
        f.input :period_end

        # Overview
        f.input :grant_count
        # TODO: f.input :recipient_count

        # TODO: f.input :amount_awarded_sum
        # TODO: f.input :amount_awarded_mean
        # TODO: f.input :amount_awarded_median
        # TODO: f.input :amount_awarded_min
        # TODO: f.input :amount_awarded_max
        f.input :amount_awarded_distribution

        # TODO: f.input :duration_awarded_months_mean
        # TODO: f.input :duration_awarded_months_median
        # TODO: f.input :duration_awarded_months_min
        # TODO: f.input :duration_awarded_months_max
        # TODO: f.input :duration_awarded_months_distribution
        f.input :award_month_distribution

        # Recipient
        # TODO: f.input :org_type_distribution
        # TODO: f.input :operating_for_distribution
        # TODO: f.input :income_distribution
        # TODO: f.input :employees_distribution
        # TODO: f.input :volunteers_distribution

        # Beneficiary
        # TODO: f.input :gender_distribution
        # TODO: f.input :age_group_distribution
        # TODO: f.input :beneficiary_distribution

        # Location
        # TODO: f.input :geographic_scale_distribution
        f.input :country_distribution
        # TODO: f.input :district_distribution
      end
    end
    f.actions
  end
end

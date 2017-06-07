ActiveAdmin.register Fund do
  config.per_page = 100

  permit_params :funder_id, :type_of_fund, :name, :description, :open_call,
                :active, :currency, :application_link, :key_criteria,
                :restrictions_known, :skip_beehive_data, :open_data,
                :period_start, :period_end, :grant_count, :amount_awarded_sum,
                :amount_awarded_distribution, :award_month_distribution,
                :country_distribution, :sources, :national,
                :org_type_distribution, :income_distribution, :slug,
                :beneficiary_distribution, :grant_examples,
                :geographic_scale_limited, country_ids: [], district_ids: [],
                                           restriction_ids: [], tags: []

  controller do
    def find_resource
      Fund.find_by(slug: params[:id])
    end
  end

  index do
    selectable_column
    column :slug
    column :active
    column 'year end' do |o|
      o&.period_end&.strftime('%Y')
    end
    column 'org_type' do |fund|
      check_presence(fund, 'org_type_distribution')
    end
    column 'income' do |fund|
      check_presence(fund, 'income_distribution')
    end
    column :geographic_scale_limited
    column :national
    column :districts do |fund|
      fund.districts.count
    end
    actions
  end

  filter :funder, input_html: { class: 'chosen-select' }
  filter :slug
  filter :active
  filter :open_data
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
      row :restrictions_known
      row :restrictions do |fund|
        fund.restrictions.each do |r|
          li r.details
        end
      end
      if fund.open_data
        row :open_data
        row :sources
        row :period_start
        row :period_end
        row :grant_count
        row :amount_awarded_sum
        row :amount_awarded_distribution
        row :award_month_distribution
        row :org_type_distribution
        row :income_distribution
        row :beneficiary_distribution
        row :grant_examples
        row :country_distribution
      end
    end
  end

  form do |f|
    f.inputs do
      inputs 'Basics' do
        f.input :slug
        f.input :funder, input_html: { class: 'chosen-select' }
        f.input :type_of_fund, input_html: { value: 'Grant' }
        f.input :name
        f.input :description
        f.input :open_call
        f.input :active
        f.input :currency, input_html: { value: 'GBP' }
        f.input :application_link
        f.input :key_criteria
        f.input :tags, as: :select, collection: Fund.pluck(:tags).flatten.uniq,
                       input_html: { multiple: true, class: 'chosen-select' }
      end

      inputs 'Restrictions' do
        f.input :restrictions_known
        f.input :restrictions, collection: Restriction.pluck(:details, :id),
                               input_html: { multiple: true,
                                             class: 'chosen-select' }
      end

      inputs 'Geography' do
        f.input :countries, collection: Country.pluck(:name, :id),
                            input_html: { multiple: true,
                                          class: 'chosen-select' }
        f.input :geographic_scale_limited
        f.input :national
        f.input :districts, collection: District.pluck(:name, :id),
                            input_html: { multiple: true,
                                          class: 'chosen-select' }
      end

      inputs 'Open Data' do
        f.input :skip_beehive_data, as: :boolean
        f.input :open_data
        f.input :sources
        f.input :period_start
        f.input :period_end

        # Overview
        f.input :grant_count
        f.input :amount_awarded_sum
        f.input :amount_awarded_distribution
        f.input :award_month_distribution

        # Recipient
        f.input :org_type_distribution
        f.input :income_distribution
        f.input :beneficiary_distribution
        f.input :grant_examples

        # Location
        f.input :country_distribution
      end
    end
    f.actions
  end
end

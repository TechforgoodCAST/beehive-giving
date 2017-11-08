ActiveAdmin.register Fund do
  config.per_page = 100

  permit_params :funder_id, :type_of_fund, :name, :description, :open_call,
                :state, :currency, :application_link, :key_criteria,
                :restrictions_known, :skip_beehive_data, :open_data,
                :period_start, :period_end, :grant_count, :amount_awarded_sum,
                :amount_awarded_distribution, :award_month_distribution,
                :country_distribution, :sources, :national,
                :org_type_distribution, :income_distribution, :slug,
                :beneficiary_distribution, :grant_examples,
                :geographic_scale_limited, :geo_area_id,
                :min_amount_awarded_limited, :min_amount_awarded,
                :max_amount_awarded_limited, :max_amount_awarded,
                :min_duration_awarded_limited, :min_duration_awarded,
                :max_duration_awarded_limited, :max_duration_awarded,
                :min_org_income_limited, :min_org_income,
                :max_org_income_limited, :max_org_income,
                country_ids: [], district_ids: [], restriction_ids: [],
                tags: [], permitted_costs: [], permitted_org_types: [],
                theme_ids: []

  controller do
    def find_resource
      scoped_collection.find_by_hashid(params[:id])
    end
  end

  index do
    selectable_column
    column :slug
    column :state
    column 'year end' do |o|
      o&.period_end&.strftime('%Y')
    end
    column 'Org Type' do |fund|
      check_presence(fund, 'org_type_distribution')
    end
    column 'Income' do |fund|
      check_presence(fund, 'income_distribution')
    end
    column :open_data
    column "Geo", :geo_area
    column "Grants", :grant_count
    column :last_updated do |fund|
      fund.updated_at.strftime("%F")
    end
    actions
  end

  filter :funder, input_html: { class: 'chosen-select' }
  filter :slug
  filter :state, as: :select
  filter :open_data
  filter :updated_at
  config.sort_order = 'updated_at_desc'

  show do
    attributes_table do
      row :slug
      row :funder do |fund|
        link_to fund.funder.name, [:admin, fund.funder]
      end
      row :name
      row :type_of_fund
      row :description do fund.description.html_safe end
      row :open_call
      row :state
      row :currency
      row :application_link do
        "<a href=\"#{fund.application_link}\">#{fund.application_link}</a>".html_safe
      end
      row :key_criteria do fund.key_criteria.html_safe end
      row :tags do
        fund.tags.each.map{|r| "<span class=\"status_tag\">#{r}</span>"}.join(" ").html_safe
      end
      row :themes do
        fund.themes.each.map{|t| "<span class=\"status_tag\">#{t.name}</span>"}.join(" ").html_safe
      end
    end

    tabs do
      tab :restrictions do
        attributes_table do
          row :restrictions_known
          row :restrictions do
            fund.restrictions.each.map{|r| "<li>#{r.details}</li>"}.join("").html_safe
          end
          row :permitted_costs do
            fund.permitted_costs.join("").html_safe
          end
          row :permitted_org_types do
            fund.permitted_org_types.each.map{|t| "<li>#{ORG_TYPES[t+1][0]}</li>"}.join("").html_safe
          end
          row :min_amount_awarded_limited
          row :min_amount_awarded
          row :max_amount_awarded_limited
          row :max_amount_awarded
          row :min_duration_awarded_limited
          row :min_duration_awarded
          row :max_duration_awarded_limited
          row :max_duration_awarded
          row :min_org_income_limited
          row :min_org_income
          row :max_org_income_limited
          row :max_org_income
        end
      end

      if fund.open_data
        tab :open_data do
          attributes_table do
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

      tab :geography do
        attributes_table do
          row :geo_area
          row :geographic_scale_limited
          row :national
        end
      end
    end
  end

  form do |f|
    f.inputs 'Basics' do
      f.input :slug
      f.input :funder, input_html: { class: 'chosen-select' }
      f.input :type_of_fund, input_html: { value: 'Grant' }
      f.input :name
      f.input :description
      f.input :open_call
      f.input :state, as: :select, collection: Fund::STATES
      f.input :currency, input_html: { value: 'GBP' }
      f.input :application_link
      f.input :key_criteria
      f.input :tags, as: :select, collection: Fund.pluck(:tags).flatten.uniq,
                     input_html: { multiple: true, class: 'chosen-select' }
      f.input :themes, collection: Theme.pluck(:name, :id),
                       input_html: { multiple: true, class: 'chosen-select' }
    end

    tabs do
      tab :restrictions do
        f.inputs 'Restrictions' do
          f.input :permitted_costs, as: :select, collection: FUNDING_TYPES,
                           input_html: { multiple: true, class: 'chosen-select' }
          f.input :permitted_org_types, as: :select, collection: ORG_TYPES.map{|o| [o[0], o[1]] },
                               input_html: { multiple: true, class: 'chosen-select' }
          f.input :restrictions_known
          f.input :restrictions, collection: Restriction.pluck(:details, :invert, :id).map { |r| [("#{r[0]} [INVERT]" if r[1]) || r[0], r[2]] },
                                 input_html: { multiple: true,
                                               class: 'chosen-select' }
          f.input :min_amount_awarded_limited
          f.input :min_amount_awarded
          f.input :max_amount_awarded_limited
          f.input :max_amount_awarded
          f.input :min_duration_awarded_limited
          f.input :min_duration_awarded
          f.input :max_duration_awarded_limited
          f.input :max_duration_awarded
          f.input :min_org_income_limited
          f.input :min_org_income
          f.input :max_org_income_limited
          f.input :max_org_income
        end

        inputs 'Geography' do
          f.input :geo_area, input_html: { class: 'chosen-select' }
          f.input :geographic_scale_limited
          f.input :national
        end
      end

      tab :open_data do

        f.inputs do
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
    end
    f.actions
  end
end

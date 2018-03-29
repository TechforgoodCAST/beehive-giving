ActiveAdmin.register Fund do
  config.per_page = 100

  permit_params :funder_id, :name, :description, :open_call,
                :state, :currency, :application_link, :key_criteria,
                :restrictions_known, :priorities_known,
                :featured, :skip_beehive_data, :open_data,
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
                :pretty_name,
                country_ids: [], district_ids: [], theme_ids: [],
                tags: [], permitted_costs: [], permitted_org_types: [],
                questions_attributes: [:id, :group, :criterion, :criterion_id, :criterion_type, :_destroy]

  controller do
    def find_resource
      scoped_collection.find_by_hashid(params[:id])
    end
  end

  scope("Full funds", default: true) { |scope| scope.where(state: ["inactive", "active"]) }
  scope("Stubs") { |scope| scope.where(state: ["draft", "stub"]) }

  index do
    selectable_column
    # column :slug
    column :funder
    column :name
    column :featured
    column :state
    column 'year end' do |o|
      o&.period_end&.strftime('%Y')
    end
    column :open_data
    column "Geo", :geo_area
    column "Grants", :grant_count
    column "Requests" do |fund|
      fund.requests.size
    end
    column :last_updated do |fund|
      fund.updated_at.strftime("%F")
    end
    actions
  end

  filter :funder, input_html: { class: 'chosen-select' }
  filter :slug
  filter :state, as: :select
  filter :featured
  filter :open_data
  filter :updated_at
  config.sort_order = 'updated_at_desc'

  show do
    tabs do
      tab :summary do
        attributes_table title: 'Summary' do
          row :funder do |fund|
            link_to fund.funder.name, [:admin, fund.funder]
          end
          row :name
          row :state
          row :description do fund.description_html.html_safe end
          row :application_link do
            "<a href=\"#{fund.application_link}\">#{fund.application_link}</a>".html_safe
          end
          row :key_criteria do fund.key_criteria_html.html_safe end
          row :themes do
            fund.themes.each.map do |t|
              "<span class='status_tag'>#{t.name}</span>"
            end.join(" \&bull; ").html_safe
          end
        end
      end
      tab :admin do
        attributes_table do
          row :slug
          row :pretty_name
          row :open_call
          row :featured
          row :currency
        end
      end
    end

    tabs do
      tab :eligibilty do
        attributes_table title: 'Eligibility' do
          attributes_table title: 'Amount' do
            row :min_amount_awarded_limited
            row :min_amount_awarded
            row :max_amount_awarded_limited
            row :max_amount_awarded
          end

          attributes_table title: 'Duration' do
            row :min_duration_awarded_limited
            row :min_duration_awarded
            row :max_duration_awarded_limited
            row :max_duration_awarded
          end

          attributes_table title: 'Income' do
            row :min_org_income_limited
            row :min_org_income
            row :max_org_income_limited
            row :max_org_income
          end

          attributes_table title: 'Location' do
            row 'Work must take place in', &:geo_area
            row 'Work is limited to specific areas', &:geographic_scale_limited
            row 'Work must have a national footprint', &:national
          end

          if fund.restrictions_known?
            attributes_table title: 'Quiz' do
              row :restrictions_known
              row :restrictions do
                labels = {
                  'Recipient' => 'Is your organisation...',
                  'Proposal' => 'Is your funding proposal for...'
                }
                invert = { true => 'Must', false => 'Must not' }

                fund.restrictions.group_by { |r| [r.category, r.invert] }.map do |k, v|
                  li = v.map { |r| "<li>#{r.details}</li>" }.join
                  "
                    <i>#{invert[k[1]]}</i><br/>
                    <strong>#{labels[k[0]]}</strong>
                    <ul>#{li}</ul>
                  "
                end.join.html_safe
              end
            end
          end

          attributes_table title: 'Recipient' do
            row :permitted_org_types do
              fund.permitted_org_types.each.map{|t| "<li>#{ORG_TYPES[t+1][0]}</li>"}.join("").html_safe
            end
          end

          attributes_table title: 'Type of funding' do
            row :permitted_costs do
              fund.permitted_costs.each.map{|t| "<li>#{FUNDING_TYPES[t][0]}</li>"}.join("").html_safe
            end
          end
        end
      end

      tab :suitability do
        attributes_table title: 'Suitability' do
          attributes_table title: 'Quiz' do
            row :priorities_known
          end
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
    end
  end

  form do |f|
    f.inputs 'Basics' do
      f.input :slug
      f.input :funder, input_html: { class: 'chosen-select' }
      f.input :name
      f.input :pretty_name
      f.input :description
      f.input :open_call
      f.input :featured
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

        f.inputs 'Questions' do
          f.input :restrictions_known
          f.input :priorities_known
          f.has_many :questions, heading: false, allow_destroy: true do |q|
            q.input :group
            q.input :criterion_type, as: :select, collection: %W[Restriction Priority]
            q.input :criterion, collection: Criterion.pluck(:details, :invert, :id, :type).map { |r| ["#{r[3]}: #{r[0]}#{(" [INVERT]" if r[1])}", r[2]] },
                                input_html: { class: 'chosen-select' }
            q.actions
          end
        end
      end

      tab :open_data do

        f.inputs do
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

    f.inputs 'Options' do
      f.input :skip_beehive_data, as: :boolean
    end

    f.actions
  end
end

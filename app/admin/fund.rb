ActiveAdmin.register Fund do
  config.sort_order = 'updated_at_desc'

  permit_params :description, :funder_id, :geo_area_id, :links, :name,
                :proposal_all_in_area, :proposal_area_limited,
                :proposal_categories, :proposal_max_amount,
                :proposal_max_duration, :proposal_min_amount,
                :proposal_min_duration, :proposal_permitted_geographic_scales,
                :recipient_categories, :recipient_max_income,
                :recipient_min_income, :state, :state, :website,
                theme_ids: [],
                questions_attributes: [
                  :id, :criterion_id, :criterion_type, :criterion, :group,
                  :_destroy
                ]

  controller do
    def find_resource
      scoped_collection.find_by_hashid(params[:id])
    end

    def scoped_collection
      super.includes(:funder, :geo_area)
    end
  end

  scope('All', default: true, &:all)
  scope('Draft') { |scope| scope.where(state: 'draft') }
  scope('Active') { |scope| scope.where(state: 'active') }
  scope('Inactive') { |scope| scope.where(state: 'inactive') }

  index do
    selectable_column
    column :funder
    column :name
    column :state
    column :geo_area
    column :updated_at
    actions
  end

  filter :funder, input_html: { class: 'choices-select' }
  filter :slug
  filter :state, as: :select
  filter :updated_at

  show do
    tabs do
      tab :summary do
        attributes_table title: 'Summary' do
          row :state
          row :funder do |fund|
            link_to fund.funder.name, [:admin, fund.funder]
          end
          row :name
          row(:description) { fund.description_html.html_safe }
          row :website do |fund|
            "<a href='#{fund.website}'>#{fund.website}</a>".html_safe
          end
          row :links do |fund|
            list = fund.links.map do |k, v|
              "<li>#{k} - <a href='#{v}'>#{v}</a></li>".html_safe
            end.join
            "<ul>#{list}</ul>".html_safe if list.present?
          end
          row :themes do |fund|
            fund.themes.map do |t|
              "<span class='status_tag'>#{t.name}</span>"
            end.join(" \&bull; ").html_safe
          end
        end
      end
      tab :admin do
        attributes_table do
          row :id
        end
      end
    end

    attributes_table title: 'Eligibility' do
      attributes_table title: 'Amount' do
        row :proposal_min_amount
        row :proposal_max_amount
      end

      attributes_table title: 'Duration' do
        row :proposal_min_duration
        row :proposal_max_duration
      end

      attributes_table title: 'Income' do
        row :recipient_min_income
        row :recipient_max_income
      end

      attributes_table title: 'Location' do
        row :proposal_permitted_geographic_scales do |fund|
          fund.proposal_permitted_geographic_scales.map do |s|
            "<span class='status_tag'>#{s}</span>"
          end.join(" \&bull; ").html_safe
        end
        row 'Work is limited to specific area?', &:proposal_area_limited
        row 'All work must take place in area?', &:proposal_all_in_area
        row 'Work must take place in', &:geo_area
      end

      attributes_table title: 'Proposal Categories' do
        row :proposal_categories do |fund|
          labels = Proposal::CATEGORIES.values.reduce({}, :merge)
          fund.proposal_categories.map do |c|
            "<span class='status_tag'>#{labels[c]}</span>"
          end.join(" \&bull; ").html_safe
        end
      end

      attributes_table title: 'Recipient Categories' do
        row :recipient_categories do |fund|
          labels = Recipient::CATEGORIES.values.reduce({}, :merge)
          fund.proposal_categories.map do |c|
            "<span class='status_tag'>#{labels[c]}</span>"
          end.join(" \&bull; ").html_safe
        end
      end

      attributes_table title: 'Quiz' do
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

    attributes_table title: 'Suitability' do
      attributes_table title: 'Quiz' do
        row :priorities
      end
    end
  end

  form do |f|
    inputs 'Basics' do
      input :state, as: :select, collection: Fund::STATES
      input :funder, input_html: { class: 'choices-select' }
      input :name
      input :description
      input :website
      input :links
      input :themes, collection: Theme.pluck(:name, :id),
                     input_html: { multiple: true, class: 'choices-select' }
    end

    panel 'Eligibility' do
      inputs 'Amount' do
        input :proposal_min_amount
        input :proposal_max_amount
      end

      inputs 'Duration' do
        input :proposal_min_duration
        input :proposal_max_duration
      end

      inputs 'Income' do
        input :recipient_min_income
        input :recipient_max_income
      end

      inputs 'Location' do
        input :proposal_permitted_geographic_scales, as: :select, collection: Proposal::GEOGRAPHIC_SCALES.invert, input_html: { multiple: true, class: 'choices-select' }
        input :proposal_area_limited
        input :proposal_all_in_area
        input :geo_area, input_html: { class: 'choices-select' }
      end

      inputs 'Proposal Categories' do
        input :proposal_categories, as: :select, collection: Proposal::CATEGORIES.values.inject(:merge).invert, input_html: { multiple: true, class: 'choices-select' }
      end

      inputs 'Recipient Categories' do
        input :recipient_categories, as: :select, collection: Recipient::CATEGORIES.values.inject(:merge).invert, input_html: { multiple: true, class: 'choices-select' }
      end

      inputs 'Questions' do
        has_many :questions, heading: false, allow_destroy: true do |q|
          q.input :group
          q.input :criterion_type, as: :select, collection: %w[Restriction Priority]
          q.input :criterion, collection: Criterion.pluck(:details, :invert, :id, :type).map { |r| ["#{r[3]}: #{r[0]}#{(" [INVERT]" if r[1])}", r[2]] },
                              input_html: { class: 'choices-select' }
          q.actions
        end
      end
    end

    f.actions
  end
end

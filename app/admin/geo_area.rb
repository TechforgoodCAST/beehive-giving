ActiveAdmin.register GeoArea do

  permit_params :name, :short_name,
                country_ids: [], district_ids: [],
                fund_ids: []

  filter :districts, input_html: { class: 'chosen-select' }
  filter :countries, input_html: { class: 'chosen-select' }
  filter :name
  filter :short_name

  index do
    selectable_column
    column :name
    column :short_name
    column :countries do |geo|
      geo.countries.count
    end
    column :districts do |geo|
      geo.districts.count
    end
    column :funds do |geo|
      geo.funds.count
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :short_name
      row :countries do |geo|
        geo.countries.map{|c| "<span class=\"status_tag\">#{c&.name}</span>"}.join(" ").html_safe
      end
      row :districts do |geo|
        geo.districts.map{|c| "<span class=\"\">#{c&.name}</span>"}.join(", ").html_safe
      end
      row :funds do |geo|
        geo.funds.map{|c| "<span class=\"\">#{c&.slug}</span>"}.join(", ").html_safe
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :short_name
      f.input :countries, collection: Country.pluck(:name, :id),
                          input_html: { multiple: true,
                                        class: 'chosen-select' }
      f.input :districts, collection: District.pluck(:name, :id),
                          input_html: { multiple: true,
                                        class: 'chosen-select' }
      f.input :funds, collection: Fund.pluck(:slug, :id),
                          input_html: { multiple: true,
                                        class: 'chosen-select' }
    end
    f.actions
  end
end

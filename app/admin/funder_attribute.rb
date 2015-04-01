ActiveAdmin.register FunderAttribute do
  config.sort_order = 'created_at_asc'

  permit_params :funder_id, :year, :grant_count, :application_count, :enquiry_count, :non_financial_support,
  application_process_ids: [], application_support_ids: [], reporting_requirement_ids: []

  index do
    selectable_column
    column :year
    column "Funder" do |attribute|
      link_to attribute.funder.name, [:admin, attribute.funder]
    end
    column :grant_count
    column :application_count
    column :enquiry_count
    actions
  end

  filter :year, as: :select
  filter :funder
  filter :application_processes, label: "Application process", member_label: :label
  filter :application_supports, label: "Application support", member_label: :label
  filter :non_financial_support, as: :select
  filter :reporting_requirements, label: "Reporting requirements", member_label: :label
  filter :updated_at

  show do
    attributes_table do
      row("Year of record") { |r| r.year }
      row "Funder" do |attribute|
        attribute.funder
      end
      row :grant_count
      row :application_count
      row :enquiry_count
      row "Application process" do |attribute|
        attribute.application_processes.each do |t|
          li t.label
        end
      end
      row "Application support" do |attribute|
        attribute.application_supports.each do |t|
          li t.label
        end
      end
      row :non_financial_support
      row "Reporting requirements" do |attribute|
        attribute.reporting_requirements.each do |t|
          li t.label
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :funder
      f.input :year, as: :select, collection: FunderAttribute::VALID_YEARS.map { |label| label }
      f.input :application_count
      f.input :enquiry_count
      f.input :application_processes, as: :select, input_html: {multiple: true}, member_label: :label, label: "Application process"
      f.input :application_supports, as: :select, input_html: {multiple: true}, member_label: :label, label: "Application support"
      f.input :non_financial_support, as: :select, collection: FunderAttribute::NON_FINANCIAL_SUPPORT.map { |label| label }
      f.input :reporting_requirements, as: :select, input_html: {multiple: true}, member_label: :label, label: "Reporting requirements"
    end
    f.actions
  end

end

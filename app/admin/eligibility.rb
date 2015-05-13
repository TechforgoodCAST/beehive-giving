ActiveAdmin.register Eligibility do

  permit_params :recipient_id, :restriction_id, :eligible

  form do |f|
    f.inputs do
      f.input :recipient
      f.input :restriction, member_label: :details
      f.input :eligible
    end
    f.actions
  end

  index do
    column("Recipient") { |e| e.recipient.name }
    column("Restrition") { |e| e.restriction.details }
    column("Funders") do |e|
      e.restriction.funders.each do |f|
        li f.name
      end
    end
    column :eligible
    actions
  end

  filter :recipient, input_html: {class: 'chosen-select'}
  filter :restriction, member_label: :details, input_html: {class: 'chosen-select'}
  filter :eligible

  show do
    attributes_table do
      row("Recipient") { |e| e.recipient }
      row("Restrition") { |e| e.restriction.details }
      row("Funders") do |e|
        e.restriction.funders.each do |f|
          li f.name
        end
      end
      row :eligible
    end
  end

end

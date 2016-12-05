ActiveAdmin.register Eligibility do

  permit_params :recipient_id, :restriction_id, :eligible

  controller do
    def scoped_collection
      Eligibility.includes(:recipient, :restriction)
    end
  end

  form do |f|
    f.inputs do
      f.input :recipient
      f.input :restriction, member_label: :details
      f.input :eligible
    end
    f.actions
  end

  index do
    selectable_column
    column('Recipient') { |e| e.recipient.name }
    column('Restrition') { |e| e.restriction.details }
    column('Funders') do |e|
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
      row('Recipient', &:recipient)
      row('Restrition') { |e| e.restriction.details }
      row('Funders') do |e|
        e.restriction.funders.uniq.each do |f|
          li f.name
        end
      end
      row('Funding streams') do |e|
        e.restriction.funders.uniq.each do |f|
          f.funding_streams.each do |fs|
            li fs.label
          end
        end
      end
      row :eligible
    end
  end

end

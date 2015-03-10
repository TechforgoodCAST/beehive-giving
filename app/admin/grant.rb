ActiveAdmin.register Grant do
  config.sort_order = 'created_at_asc'

  permit_params :funding_stream, :grant_type, :attention_how, :amount_awarded,
  :amount_applied, :installments, :approved_on, :start_on, :end_on, :attention_on, :applied_on,
  :recipient_id, :funder_id

  index do
    column "Organisation", :recipient do |grant|
      if grant.recipient
        link_to grant.recipient.name, [:admin, grant.recipient]
      end
    end
    column "Funder", :funder do |grant|
      if grant.funder
        link_to grant.funder.name, [:admin, grant.funder]
      end
    end
    column :amount_awarded
    actions
  end
end

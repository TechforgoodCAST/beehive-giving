ActiveAdmin.register Proposal do

  # controller do
  #   def scoped_collection
  #     Feature.includes(:funder, :recipient)
  #   end
  # end

  index do
    selectable_column
    column 'Recipient' do |proposal|
      link_to proposal.recipient.name, [:admin, proposal]
    end
    column :title
    column :tagline
    column :total_costs do |proposal|
      number_to_currency(proposal.total_costs, unit: '£', precision: 0)
    end
    column 'Locations', :districts do |proposal|
      proposal.districts.each do |d|
        li d.label
      end
    end
  end
end

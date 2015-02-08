ActiveAdmin.register Feature do
  index do
    column :data_requested
    column "for", :funder do |feature|
      link_to feature.funder.name, [:admin, feature.recipient]
    end
    column "by", :recipient do |feature|
      link_to feature.recipient.name, [:admin, feature.recipient]
    end
    column "at", :created_at
    actions
  end
end
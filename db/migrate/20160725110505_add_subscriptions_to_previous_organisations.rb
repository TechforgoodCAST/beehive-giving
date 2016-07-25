class AddSubscriptionsToPreviousOrganisations < ActiveRecord::Migration
  def up
    Organisation.all.find_each do |org|
      org.create_subscription
    end
  end
end

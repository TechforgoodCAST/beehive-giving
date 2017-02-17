class MigratePolymorphicEligibilities < ActiveRecord::Migration[5.0]
  def up
    Restriction.where(id: [4, 6, 7, 8, 42, 57, 59, 60, 44, 5, 61, 62, 175, 63, 43, 65, 66, 67, 68, 71, 73, 72, 75, 76, 80, 83, 84, 85, 86, 87, 88, 105, 106, 107, 109, 113, 100, 116, 117, 119, 118, 147, 167, 171, 174, 179, 188, 189, 195, 178, 210, 212, 214, 216, 217, 219, 220]).update_all(category: 'Organisation')

    Eligibility.where(restriction_id: Restriction.where(category: 'Organisation').pluck(:id)).update_all(category_type: 'Organisation')

    Recipient.joins(:eligibilities, :proposals).distinct.find_each { |r| r.proposals.last.check_eligibility! }
  end
end

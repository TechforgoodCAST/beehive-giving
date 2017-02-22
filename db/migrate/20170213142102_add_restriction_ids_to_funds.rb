class AddRestrictionIdsToFunds < ActiveRecord::Migration[5.0]
  def change
    add_column :funds, :restriction_ids, :jsonb, null: false, default: []
    Fund.joins(:restrictions).distinct.each do |f|
      f.skip_beehive_data = 1
      f.save!
      print '.'
    end
  end
end

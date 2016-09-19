class AddFundsCheckedToOrganisations < ActiveRecord::Migration
  def up
    add_column :organisations, :funds_checked, :integer, default: 0, null: false

    Recipient.joins(:recipient_funder_accesses).group(:recipient_id).count.each do |k, v|
      Recipient.find(k).update_column(:funds_checked, v)
      print '.'
    end
  end

  def down
    remove_column :organisations, :funds_checked
  end
end

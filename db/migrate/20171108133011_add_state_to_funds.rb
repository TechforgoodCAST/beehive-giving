class AddStateToFunds < ActiveRecord::Migration[5.1]
  def change
    add_column :funds, :state, :string, null: false, default: 'draft'

    reversible do |dir|
      dir.up do
        Fund.where(active: true).update_all(state: 'active')
        Fund.where(active: false).update_all(state: 'inactive')
      end
      dir.down do
        Fund.where(state: 'active').update_all(active: true)
        Fund.where(state: 'inactive').update_all(active: false)
      end
    end

    remove_column :funds, :active, :boolean
  end
end

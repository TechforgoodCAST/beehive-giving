class EligibilitiesPolymorphic < ActiveRecord::Migration[5.0]
  def change
    rename_column :eligibilities, :recipient_id, :category_id
    change_column :eligibilities, :category_id, :integer, null: false
    change_column :eligibilities, :restriction_id, :integer, null: false
    change_column :eligibilities, :eligible, :boolean, null: false
    add_column :eligibilities, :category_type, :string, default: 'Proposal', null: false
    add_index :eligibilities, :category_type
  end
end

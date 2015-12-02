class AddOtherToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :beneficiaries_other_required, :boolean
    add_column :profiles, :beneficiaries_other, :string
    add_column :profiles, :implementors_other_required, :boolean
    add_column :profiles, :implementors_other, :string
    add_column :profiles, :implementations_other_required, :boolean
    add_column :profiles, :implementations_other, :string
  end
end

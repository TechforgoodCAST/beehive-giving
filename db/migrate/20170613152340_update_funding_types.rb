class UpdateFundingTypes < ActiveRecord::Migration[5.0]
  def up
    add_column :proposals, :funding_type_temp, :integer

    Proposal.where(funding_type: nil).update_all(funding_type_temp: 0)
    Proposal.where(funding_type: "Don't know").update_all(funding_type_temp: 0)
    Proposal.where(funding_type: 'Capital funding - purchase and refurbishment of equipment, and buildings').update_all(funding_type_temp: 1)
    Proposal.where(funding_type: 'Revenue funding - running costs, salaries and activity costs').update_all(funding_type_temp: 2)
    Proposal.where(funding_type: 'Other').update_all(funding_type_temp: 3)

    remove_column :proposals, :funding_type, :string
    rename_column :proposals, :funding_type_temp, :funding_type
  end

  def down
    add_column :proposals, :funding_type_temp, :string

    Proposal.where(funding_type: 0).update_all(funding_type_temp: "Don't know")
    Proposal.where(funding_type: 1).update_all(funding_type_temp: 'Capital funding - purchase and refurbishment of equipment, and buildings')
    Proposal.where(funding_type: 2).update_all(funding_type_temp: 'Revenue funding - running costs, salaries and activity costs')
    Proposal.where(funding_type: 3).update_all(funding_type_temp: 'Other')

    remove_column :proposals, :funding_type, :integer
    rename_column :proposals, :funding_type_temp, :funding_type
  end
end

class AddUserToProposal < ActiveRecord::Migration[5.1]
  def change
    add_reference :proposals, :user, foreign_key: true
    rename_column :proposals, :private, :permit_funder_verification
    add_column :proposals, :access_token, :string
    add_column :proposals, :legacy, :boolean
    add_column :proposals, :private, :datetime
  end
end

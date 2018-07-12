class AddPublicConsentToProposals < ActiveRecord::Migration[5.1]
  def change
    add_column :proposals, :public_consent, :boolean
  end
end

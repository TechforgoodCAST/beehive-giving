class AddEligibilityToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :proposals, :eligibility, :jsonb, default: {}, null: false
  end
end

class CreateBeneficiariesProfiles < ActiveRecord::Migration
  def change
    create_table :beneficiaries_profiles do |t|
      t.references :beneficiary
      t.references :profile
    end
  end
end

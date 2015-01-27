class CreateBeneficiariesProfiles < ActiveRecord::Migration
  def change
    create_table :beneficiaries_profiles do |t|
      t.references :beneficiary
      t.references :profile
    end

    create_table :implementations_profiles do |t|
      t.references :implementation
      t.references :profile
    end

    create_table :markets_profiles do |t|
      t.references :market
      t.references :profile
    end
  end
end

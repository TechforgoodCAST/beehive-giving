class CreateBeneficiaries < ActiveRecord::Migration
  def up
    create_table :beneficiaries do |t|
      t.string :label

      t.timestamps null: false
    end

    [
      "People who face challenges with their physical health",
      "People who face challenges with their mental health",
      "People in education",
      "Unemployed people",
      "People who face income poverty",
      "People from a particular ethnic background",
      "People affected by or involved with criminal activities",
      "People who face challenges with housing",
      "People who face challenges within their family or relationships",
      "Other organisations",
      "Other"
    ].each do |state|
      Beneficiary.create(label:state)
    end
  end

  def down
    drop_table :beneficiaries
  end
end

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

    create_table :implementations do |t|
      t.string :label

      t.timestamps null: false
    end

    [
      "Staff to Beneficiary (A paid member of staff works with a beneficiary)",
      "Volunteer to Beneficiary (A voluntary member of staff works with a beneficiary)",
      "Beneficiary to Beneficiary (A beneficiary works with another beneficiary)",
      "Software to Beneficiary (Software for a beneficiary or workers)",
      "Goods to Beneficiary (Physical goods for a beneficiary or workers)",
      "Third party to Beneficiary (A partner agency works with a beneficiary)",
      "Research (Research that affects a beneficiary)",
      "Campaign to Beneficiary (A campaign that affects a beneficiary)"
    ].each do |state|
      Implementation.create(label:state)
    end
  end

  def down
    drop_table :beneficiaries
    drop_table :implementations
  end
end

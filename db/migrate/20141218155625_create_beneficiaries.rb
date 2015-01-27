class CreateBeneficiaries < ActiveRecord::Migration
  def up
    create_table :beneficiaries do |t|
      t.string :label

      t.timestamps null: false
    end

    create_table :implementations do |t|
      t.string :label

      t.timestamps null: false
    end

    create_table :markets do |t|
      t.string :label

      t.timestamps null: false
    end
  end

  def down
    drop_table :beneficiaries
    drop_table :implementations
    drop_table :markets
  end
end

class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :organisation
      t.string :gender, :currency, :goods_services, :who_pays, :who_buys,  required: true
      t.integer :year, :min_age, :max_age, :income, :expenditure, :volunteer_count, :staff_count, :job_role_count, :department_count, :goods_count, :units_count, :services_count, :beneficiaries_count, required: true

      t.timestamps
    end
  end
end

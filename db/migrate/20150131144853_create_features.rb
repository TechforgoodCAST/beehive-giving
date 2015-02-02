class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.references :funder, :recipient,  required: true
      t.boolean :data_requested

      t.timestamps null: false
    end
  end
end

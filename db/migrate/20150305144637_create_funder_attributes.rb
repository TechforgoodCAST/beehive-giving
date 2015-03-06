class CreateFunderAttributes < ActiveRecord::Migration
  def change
    create_table :funder_attributes do |t|
      t.integer :application_process
      t.date :next_deadline
      t.integer :funding_round_frequency
      t.integer :funding_streams
      t.integer :funding_type

      t.timestamps
    end
  end
end

class AddRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :requests do |t|
      t.references :fund
      t.references :recipient
      t.column :message, :string
      t.timestamps null: false
    end
  end
end

class RemoveUnusedFields < ActiveRecord::Migration[5.1]
  def up
    remove_column :users, :job_role

    remove_columns :enquiries, :recipient_id, :funder_id, :new_project,
                   :new_location, :amount_seeking, :duration_seeking,
                   :funding_stream

    drop_table :features
  end
end

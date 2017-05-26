class RemoveDocuments < ActiveRecord::Migration[5.0]
  def change
    drop_table :documents
    drop_table :documents_funds

    remove_column :funds, :documents_known
  end
end

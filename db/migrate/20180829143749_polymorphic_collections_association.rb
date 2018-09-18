class PolymorphicCollectionsAssociation < ActiveRecord::Migration[5.1]
  def change
    add_reference :proposals, :collection
    add_column :proposals, :collection_type, :string
    add_index :proposals, :collection_type
  end
end

class ChangeFundingStreamToStringFunderAttributes < ActiveRecord::Migration
  def change
    add_column :funder_attributes, :funding_stream, :string
    remove_reference :funder_attributes, :funding_stream
    drop_table :funding_streams do |t|
      t.string :label
    end
  end
end

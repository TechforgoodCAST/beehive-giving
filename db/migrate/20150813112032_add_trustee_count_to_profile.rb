class AddTrusteeCountToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :trustee_count, :integer
  end
end

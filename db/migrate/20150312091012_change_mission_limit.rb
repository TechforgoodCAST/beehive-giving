class ChangeMissionLimit < ActiveRecord::Migration
  def change
    change_column :organisations, :mission, :text, :limit => nil
  end
end

class AddOrgStatusColumnDefault < ActiveRecord::Migration
  def change
    change_column_default(:organisations, :status, 'Active - currently operational')
  end
end

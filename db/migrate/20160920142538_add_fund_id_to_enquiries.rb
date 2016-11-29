class AddFundIdToEnquiries < ActiveRecord::Migration
  def change
    add_reference :enquiries, :fund, index: true, foreign_key: true
    add_reference :enquiries, :proposal, index: true, foreign_key: true
    change_column :enquiries, :approach_funder_count, :integer, default: 0
  end
end

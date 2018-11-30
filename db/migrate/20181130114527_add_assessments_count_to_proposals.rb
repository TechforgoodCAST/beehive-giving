class AddAssessmentsCountToProposals < ActiveRecord::Migration[5.1]
  def down
    remove_column :proposals, :assessments_count
    remove_column :funders, :active_opportunities_count
    remove_column :themes, :active_opportunities_count
  end

  def up
    add_column :proposals, :assessments_count, :integer, null: false, default: 0
    add_column :funders, :active_opportunities_count, :integer, null: false, default: 0
    add_column :themes, :active_opportunities_count, :integer, null: false, default: 0

    Proposal.reset_column_information
    Proposal.find_each do |p|
      Proposal.reset_counters(p.id, :assessments)
      print 'p'
    end

    Funder.reset_column_information
    Funder.find_each do |f|
      Funder.update_counters(f.id, active_opportunities_count: f.funds.active.size)
      print 'f'
    end

    Theme.reset_column_information
    Theme.find_each do |t|
      Theme.update_counters(t.id, active_opportunities_count: t.funds.active.size)
      print 't'
    end
  end
end

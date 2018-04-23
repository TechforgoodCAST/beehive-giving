class TransitionProposalStates < ActiveRecord::Migration[5.1]
  def up
    Proposal.where(state: 'registered').update_all(state: 'incomplete')
    Proposal.where(state: 'initial').find_each do |proposal|
      if proposal.valid?
        proposal.update_column(:state, 'complete')
      else
        proposal.update_column(:state, 'invalid')
      end
      print '.'
    end
    change_column_default :proposals, :state, 'complete'
  end
end

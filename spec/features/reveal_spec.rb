require 'rails_helper'

ffeature 'RevealFunds' do

    context 'user with v2 subscription' do

        scenario 'I see a reveal button on funds pages' do
            expect(page).to have_link('Reveal', count: 6)
        end

        scenario 'Clicking on reveal button reveals that fund' do
            click_link('Reveal', match: :first)
            expect(@user.reveals.count).to eq 1 
            expect(current_page).to eq proposal_fund_path(@proposal, @fund)
        end

        scenario 'Cant reveal fund after reaching limit' do
            # reveal funds limit has been met - user clicks reveal and is presented with update page
            click_link('Reveal', match: :first)
            expect(current_page).to eq upgrade_fund_path(@recipient)
        end
    
    end

end